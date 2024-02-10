using System;
using System.Collections.Generic;
using System.Drawing;
using System.Linq;
using System.Runtime.InteropServices.WindowsRuntime;
using System.Text;
using System.Threading.Tasks;

namespace Knight_tour
{
    internal sealed class TourHandler
    {
        #region SINGLETON
        private static TourHandler instance = null;

        private TourHandler() { }

        public static TourHandler Instance
        {
            get
            {
                if (instance == null)
                    instance = new TourHandler();

                return instance;
            }
        }
        #endregion
        private MainGui gui = null;

        public int currentTour = 0;

        public List<KnightTour> tours = new List<KnightTour>();

        public void SetGui(MainGui gui) 
        {
            this.gui = gui;
        }

        public bool Initializated()
        {
            return (GetCurrent() != null);
        }

        private KnightTour GetCurrent()
        {
            if (tours != null)
            {
                if (tours.Count > 0)
                {
                    if (tours[currentTour] != null)
                    {
                        return tours[currentTour];
                    }
                }
            }

            return null;
        }

        public List<Point> GetCurrentTour()
        {
            KnightTour t = GetCurrent();
            if (t != null)
                return t.GetTour();

            return null;
        }

        public Point GetCurrentPosition()
        {
            if(tours != null)
            {
                if(tours.Count > 0) 
                {
                    if (tours[currentTour] != null)
                    {
                        var t = tours[currentTour];
                        return t.GetPosition();
                    }
                }
            }

            return new Point(-1, -1);
        }

        public void ClearAll()
        {
            tours.Clear();
        }

        public void ResetAll()
        {
            foreach(var t in tours)
            {
                t.Reset();
            }

            currentTour = 0;
        }

        public void StepForward()
        {
            KnightTour t = GetCurrent();
            if (t != null)
            {
                gui.ClearKnight(t.GetPosition());
                t.Forward();
                if(t.isFinished)
                {
                    try
                    {
                        if (tours[currentTour + 1] != null)
                        {
                            currentTour++;
                            gui.ClearBoard();
                            t = GetCurrent();
                            t.Reset();
                        }
                    }
                    catch(IndexOutOfRangeException) { }
                }

                gui.PositionKnight(t.GetPosition());
            }

            //if (tourIndex < (tour.Count - 1))
            //{
            //    
            //    //gui.listViewLastMoves.Items[tourIndex].ForeColor = SystemColors.ControlText;
            //    tourIndex++;
            //    gui.PositionKnight(tour[tourIndex]);
            //    //listViewLastMoves.Items[tourIndex].ForeColor = Color.DarkGoldenrod;
            //
            //    //UpdateStepLabel();
            //}
        }

        public void StepBackward()
        {
            KnightTour t = GetCurrent();
            if (t != null)
            {
                if (t.tourIndex == 0)
                {
                    if(currentTour > 0)
                        currentTour--;
                }
                else
                {
                    t.Backward();
                }
            }

            //if (tourIndex > 0)
            //{
            //    ClearKnight(tour[tourIndex]);
            //    listViewLastMoves.Items[tourIndex].BackColor = Color.White;
            //    tourIndex--;
            //    PositionKnight(tour[tourIndex]);
            //    listViewLastMoves.Items[tourIndex].BackColor = Color.Green;
            //
            //    UpdateStepLabel();
            //}
        }
    }
}
