using System;
using System.Collections.Generic;
using System.Linq;
using System.Drawing;
using System.Windows.Forms;
using System.Security.Cryptography.X509Certificates;
using System.Deployment.Application;

namespace Knight_tour
{
    internal class KnightTour
    {
        List<Point> tour = new List<Point>();
        public int tourIndex { private set; get; }

        public bool isFinished { private set; get; }

        public KnightTour() { }

        public Point GetPosition()
        {
            return tour[tourIndex];
        }

        public List<Point> GetTour()
        {
            return tour;
        }

        public void Init(string strTour)
        {
            List<Point> memTour = new List<Point>(tour);

            tour.Clear();
            string[] steps = strTour.Split(';');
            foreach (string step in steps)
            {
                step.Replace(' ', (char)0);

                int i = step.IndexOf('(') + 1;
                int j = step.IndexOf(')');

                string[] values = step.Substring(i, j - i).Split(',');

                try
                {
                    int x = Convert.ToInt32(values[0]);
                    int y = Convert.ToInt32(values[1]);

                    tour.Add(new Point(x, y));
                }
                catch (FormatException exc)
                {
                    tour = new List<Point>(memTour);
                    MessageBox.Show(exc.Message);
                    return;
                }
                catch (IndexOutOfRangeException exc)
                {
                    tour = new List<Point>(memTour);
                    MessageBox.Show(exc.Message);
                    return;
                }
            }

            isFinished = false;
        }

        public void Reset()
        {
            tourIndex = 0;
        }

        public void Forward()
        {
            if (tourIndex < (tour.Count - 1))
                tourIndex++;
            else
                isFinished = true;
        }

        public void Backward()
        {
            if (tourIndex > 0)
            {
                tourIndex--;
                isFinished = false;
            }
        }
    }
}
