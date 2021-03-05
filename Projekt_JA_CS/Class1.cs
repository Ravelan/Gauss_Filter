using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Projekt_JA_CS
{
    public class Class1
    {
        private int normalizeRGB(int val)
        {
            if (val < 0) val = 0;
            if (val > 255) val = 255;
            return val;
        }
        public void filter(byte[] image, int width, int height, byte[] output)
        {
            
            //int[] myMask1d = new int[] { 0, -1, 0, -1, 4, -1, 0, -1, 0 };
            int[] myMask1d = new int[] { 1, 2, 1, 2, 4, 2, 1, 2, 1 };
            //int[] myMask1d = new int[] { 1, 1, 1, 1, -8, 1, 1, 1, 1 };
            for (int y = 1; y < height - 1; y++)
            {
                for (int x = 3; x < width * 3 - 3; x += 3)
                {
                    int sumRed = 0;
                    int sumGreen = 0;
                    int sumBlue = 0;
                    int maskIndex = 0;

                    for (int pxY = -1; pxY <= 1; pxY++)
                    {
                        for (int pxX = -1; pxX <= 1; pxX++)
                        {
                            sumBlue += image[(y - pxY) * width * 3 + x + pxX * 3 + 0] * myMask1d[maskIndex];
                            sumGreen += image[(y - pxY) * width * 3 + x + pxX * 3 + 1] * myMask1d[maskIndex];
                            sumRed += image[(y - pxY) * width * 3 + x + pxX * 3 + 2] * myMask1d[maskIndex];
                            maskIndex++;
                        }
                    }
                    sumRed = normalizeRGB(sumRed/16);
                    sumGreen = normalizeRGB(sumGreen/16);
                    sumBlue = normalizeRGB(sumBlue/16);
                    output[y * width * 3 + x + 2] = (byte)sumRed;
                    output[y * width * 3 + x + 1] = (byte)sumGreen;
                    output[y * width * 3 + x + 0] = (byte)sumBlue;

                }
            }
        }
    }
}
