using Microsoft.Win32;
using System;
using System.Drawing;
using System.Runtime.InteropServices;
using System.Windows;
using System.Windows.Interop;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using System.Diagnostics;
using System.IO;
using System.Reflection;
using Color = System.Drawing.Color;
using LiveCharts;
using LiveCharts.Wpf;
using System.Threading;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace Projekt_JA
{
    /// <summary>
    /// Logika interakcji dla klasy MainWindow.xaml
    /// </summary>
    delegate void FiltrGauss_Delegate(byte[] input, int width, int height, byte[] output);

    public partial class MainWindow : Window
    {
        //histogram collections
        public SeriesCollection SeriesCollection { get; set; }
        public SeriesCollection SeriesCollectionAfter { get; set; }

        Bitmap bmp;
        Bitmap newBmp;
        //biblioteki do ładowania dll dynamicznie
        [DllImport("kernel32.dll", CharSet = CharSet.Auto, SetLastError = true)]
        private static extern IntPtr LoadLibrary(string libname);

        [DllImport("kernel32.dll", CharSet = CharSet.Auto)]
        private static extern bool FreeLibrary(IntPtr hModule);
        [DllImport("kernel32.dll", CharSet = CharSet.Ansi)]
        private static extern IntPtr GetProcAddress(IntPtr hModule, string lpProcName);



        FiltrGauss_Delegate filter; //wskaźnik na funckję wykonywującą algorytm
        public MainWindow()
        {
            InitializeComponent();
            InitHistogram();
        }
        //Load function from ASM
        private void LoadFromAsm(byte[] input, int width, int height, byte[] output)
        {
            IntPtr Handle = LoadLibrary(@"./Projekt_JA_ASM.dll");
            IntPtr funcaddr = GetProcAddress(Handle, "filter");
            if(Handle != IntPtr.Zero && funcaddr != IntPtr.Zero)
            {
                FiltrGauss_Delegate function = Marshal.GetDelegateForFunctionPointer(funcaddr, typeof(FiltrGauss_Delegate)) as FiltrGauss_Delegate;
                function.Invoke(input, width, height, output);
            }
            else
            {
                Debug.WriteLine("Handle is null");
            }
            
            FreeLibrary(Handle);
            Handle = IntPtr.Zero;
            
        }

        //Load function from CS
        private void LoadFromCs(byte[] input, int width, int height,  byte[] output)
        {
            var dllFile = new FileInfo(@"./Projekt_JA_CS.dll");
            var DLL = Assembly.LoadFile(dllFile.FullName);
            var class1Type = DLL.GetType("Projekt_JA_CS.Class1");
            dynamic c = Activator.CreateInstance(class1Type);
            c.filter(input,width,height, output);
        }

        private void Load_Photo(object sender, RoutedEventArgs e) 
        {
            OpenFileDialog openFileDialog = new OpenFileDialog();
            if(openFileDialog.ShowDialog()==true)
            {
                var fileName = openFileDialog.FileName;
                Uri fileUri = new Uri(fileName);
                Source_Image.Source = new BitmapImage(fileUri);
                bmp = new Bitmap(fileName);
                newBmp = new Bitmap(bmp);
            }
        }
        //return sum of values in mask
        private int Sumawag(int [,] wagi) 
        {
            int waga=0;
            for (int x=0;x<3;x++)
            {
                for (int y=0;y<3;y++)
                {
                    waga += wagi[x, y];
                }
            }
            if (waga == 0)
                waga = 1;
            return waga;
        }
        [DllImport("gdi32.dll", EntryPoint = "DeleteObject")]
        [return: MarshalAs(UnmanagedType.Bool)]
        public static extern bool DeleteObject([In] IntPtr hObject);
        private ImageSource ImgFromBmp( Bitmap testbmp)
        {
            var handler = testbmp.GetHbitmap();
            try
            {
                return Imaging.CreateBitmapSourceFromHBitmap(handler, IntPtr.Zero, Int32Rect.Empty, BitmapSizeOptions.FromEmptyOptions());
            }
            finally { DeleteObject(handler); }
        }
       
        public void FiltrGauss()
        {
            int width = bmp.Width;
            int height = bmp.Height;
            int pos = 0;
            byte[] rgbValues = new byte[bmp.Height * bmp.Width * 3];
            byte[] newImage = new byte[bmp.Height * bmp.Width * 3];


            System.Drawing.Rectangle rect = new System.Drawing.Rectangle(0, 0, bmp.Width, bmp.Height);
            System.Drawing.Imaging.BitmapData bmpData =
                bmp.LockBits(rect, System.Drawing.Imaging.ImageLockMode.ReadWrite,
                bmp.PixelFormat);
            int offset = Math.Abs(bmpData.Stride) - bmp.Width * 3;
            int length = Math.Abs(bmpData.Stride) * bmpData.Height;
            int bytes = Math.Abs(bmpData.Stride) * bmp.Height;
            IntPtr ptr = bmpData.Scan0;

            //copy bmp to array excluding offest
            for (int i = 0; i < bmp.Height * Math.Abs(bmpData.Stride); i += bmp.Width * 3)
            {
                System.Runtime.InteropServices.Marshal.Copy(ptr + i, rgbValues, pos, bmp.Width * 3);
                pos += bmp.Width * 3;
                i += offset;
            }
            newImage = rgbValues;

            CreateHistogram(rgbValues, SeriesCollection);

            var timer = System.Diagnostics.Stopwatch.StartNew();

            //filter.Invoke(rgbValues, width, height, newImage);
            multiThreadFiltering((int)Threads.Value, rgbValues, width, height, newImage);

            timer.Stop();
            var timeMS = timer.ElapsedMilliseconds;
            czas.Content = timeMS.ToString();

            CreateHistogram(newImage, SeriesCollectionAfter);
            pos = 0;

            //copy array to bmp
            for (int i = 0; i < bmp.Height * Math.Abs(bmpData.Stride); i += bmp.Width * 3)
            {
                System.Runtime.InteropServices.Marshal.Copy(newImage, pos, ptr + i, bmp.Width * 3);
                pos += bmp.Width * 3;
                i += offset;
            }
            
            bmp.UnlockBits(bmpData);
            Final_Image.Source = ImgFromBmp(bmp);
        }
        //activate Cs function
        private void Button_Cs(object sender, RoutedEventArgs e)
        {
            filter = LoadFromCs;
            FiltrGauss();
        }
        //acttivate asm function
        private void Button_ASM(object sender, RoutedEventArgs e)
        {
            filter = LoadFromAsm;
            FiltrGauss();
        }
        //activate multi thread filtering
        void multiThreadFiltering(int numberOfThreads, byte[] image, int width, int height, byte[] newImage)
        {
            if (numberOfThreads > height)
                numberOfThreads = (int)(height/3);
            int subArrayPosition = 0;
            int currentHeight = 0;

            int restOfRows = height % numberOfThreads;
            int numberOfRows = (int)(height / numberOfThreads);

            byte[][] subArrays = new byte[numberOfThreads][];
            byte[][] filteredSubArrays = new byte[numberOfThreads][];

            List<Task> threads = new List<Task>();
            List<MultiThreadClass> dataList = new List<MultiThreadClass>();
            
            for (int y = 0; y < height - restOfRows - 1; y += numberOfRows)
            {
                
                int startIndex = y;
                int endIndex = y + numberOfRows;

                if (restOfRows > 0)
                {
                    endIndex++;
                    restOfRows--;
                    y++;
                }
                if (startIndex > 0)
                    startIndex--;
                if (endIndex < height)
                    endIndex++;

                subArrays[subArrayPosition] = new byte[endIndex * width * 3 - startIndex * width * 3];
                int tempArrayPosition = subArrayPosition;


                Array.Copy(image, startIndex * width * 3, subArrays[tempArrayPosition], 0, endIndex * width * 3 - startIndex * width * 3);

                filteredSubArrays[tempArrayPosition] = new byte[endIndex * width * 3 - startIndex * width * 3];

                MultiThreadClass data = new MultiThreadClass(subArrays[tempArrayPosition], width, endIndex - startIndex, filteredSubArrays[tempArrayPosition], filter);
                Thread thread = new Thread(data.filtering);
                dataList.Add(data);
                threads.Add(Task.Factory.StartNew(data.gauss));
                subArrayPosition++;
            }
            Task.WaitAll(threads.ToArray());

            currentHeight = 0;
            int subImgHeight = 0;

            for (int i = 0; i < numberOfThreads; i++)
            {
                byte[] subImage = filteredSubArrays[i];
                subImgHeight += subImage.Length / (width * 3);
                if (i == 0)
                {
                    Array.Copy(subImage, 0, newImage, currentHeight, subImage.Length - width * 3);
                    currentHeight += subImage.Length / (width * 3) - 1;

                }
                else
                {

                    Array.Copy(subImage, width * 3, newImage, currentHeight * width * 3, subImage.Length - width * 3);
                    currentHeight += subImage.Length / (width * 3)-2;

                }
            }
        }
        //Create Histogram
            private void CreateHistogram(byte[] rgbValues, SeriesCollection series)
            {
            int[] R = new int[256];
            int[] G = new int[256];
            int[] B = new int[256];

            series[0].Values.Clear();
            series[1].Values.Clear();
            series[2].Values.Clear();

            for (int i = 0; i < 256; i++)
            {
                R[i] = 0;
                G[i] = 0;
                B[i] = 0;
            }

            for (int i = 0; i < rgbValues.Length-3; i += 3)
            {
                R[(int)rgbValues[i + 0]]++;
                G[(int)rgbValues[i + 1]]++;
                B[(int)rgbValues[i + 2]]++;
            }

                for (int i = 0; i < 256; i++)
                {
                    series[0].Values.Add(R[i]);
                    series[1].Values.Add(G[i]);
                    series[2].Values.Add(B[i]);
                }   
            }
        //initialize Histogram
        private void InitHistogram()
        {
            chart.AxisY.Clear();
            chart.AxisY.Add(new Axis{MinValue = 0});
            chartAfter.AxisY.Clear();
            chartAfter.AxisY.Add(new Axis{MinValue = 0}
            );
            SeriesCollection = new SeriesCollection
            {
                new LineSeries
                {
                    Title = "Red",
                    PointGeometry = null,
                    Values = new ChartValues<int>{},
                    Stroke = System.Windows.Media.Brushes.Red
                },
                new LineSeries
                {
                    Title = "Green",
                    PointGeometry = null,
                    Values = new ChartValues<int>{},
                    Stroke = System.Windows.Media.Brushes.Green
                },
                new LineSeries
                {
                    Title = "Blue",
                    PointGeometry = null,
                    Values = new ChartValues<int>{},
                    Stroke = System.Windows.Media.Brushes.Blue
                }
            };
            SeriesCollectionAfter = new SeriesCollection
            {
                new LineSeries
                {
                    Title = "Red",
                    PointGeometry = null,
                    Values = new ChartValues<int>{},
                    Stroke = System.Windows.Media.Brushes.Red
                },
                new LineSeries
                {
                    Title = "Green",
                    PointGeometry = null,
                    Values = new ChartValues<int>{},
                    Stroke = System.Windows.Media.Brushes.Green
                },
                new LineSeries
                {
                    Title = "Blue",
                    PointGeometry = null,
                    Values = new ChartValues<int>{},
                    Stroke = System.Windows.Media.Brushes.Blue
                }
            };
            DataContext = this;
        }
        //save picture
        private void Btn_Save(object sender, RoutedEventArgs e)
        {
            SaveFileDialog saveFileDialog = new SaveFileDialog();
            saveFileDialog.Filter = "JPG (*.jpg)|*.jpg|PNG (*.png)|*.png";
            if (saveFileDialog.ShowDialog() == true)
            {
                var fileName = saveFileDialog.FileName;
                var extension = System.IO.Path.GetExtension(saveFileDialog.FileName);

                switch (extension.ToLower())
                {
                    case ".jpg":
                        bmp.Save(fileName, System.Drawing.Imaging.ImageFormat.Jpeg);
                        break;
                    case ".png":
                        bmp.Save(fileName, System.Drawing.Imaging.ImageFormat.Png);
                        break;
                    default:
                        throw new ArgumentOutOfRangeException(extension);
                }
            }

        }
    }
    //temporary class for multithread
    class MultiThreadClass
    {
        private byte[] imageInput;
        private int width;
        private int height;
        private byte[] imageOutput;
        private FiltrGauss_Delegate GaussDelegat;

        public MultiThreadClass(byte[] imageInput, int width, int height, byte[] imageOutput, FiltrGauss_Delegate fun_delegate)
        {
            this.imageInput = imageInput;
            this.width = width;
            this.height = height;
            this.imageOutput = imageOutput;
            this.GaussDelegat = fun_delegate;
        }
        public void gauss()
        {
            GaussDelegat(this.imageInput, this.width, this.height, this.imageOutput);
        }
        public void filtering(object data)
        {
            MultiThreadClass cast = (MultiThreadClass)data;
            cast.GaussDelegat(cast.imageInput, cast.width, cast.height, cast.imageOutput);
        }
    };
}

