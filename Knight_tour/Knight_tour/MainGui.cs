using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Security.Policy;
using System.Text;
using System.IO;
using System.Windows.Forms;

namespace Knight_tour
{
    public partial class MainGui : Form
    {
        List<Point> memKnightTour = new List<Point>();
        List<Point> knightTour = new List<Point>();

        public MainGui()
        {
            InitializeComponent();
            this.SetStyle(ControlStyles.DoubleBuffer | ControlStyles.OptimizedDoubleBuffer, true);

            CreateBoard(8);
            PositionKnight(new Point(3, 3));
        }

        private Panel GetBoardPanel(Color c)
        {
            Panel panel = new Panel
            {
                BackColor = c,
                Dock = DockStyle.Fill,
                Location = new Point(0, 0),
                Size = new Size(50, 50),
                Name = "",
                BackgroundImageLayout = ImageLayout.Zoom,
                BorderStyle = BorderStyle.FixedSingle,
            };

            return panel;
        }

        private void CreateBoard(int size)
        {
            chessBoard.SuspendLayout();
            chessBoard.CellBorderStyle = TableLayoutPanelCellBorderStyle.None;
            chessBoard.Controls.Clear();

            chessBoard.ColumnCount = size;
            chessBoard.RowCount = size;

            Color color = UserColor.cellGreen;
            for(int i = 0; i < size; i++)
            {
                chessBoard.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 20F));

                for (int j = 0; j < size; j++)
                {
                    chessBoard.RowStyles.Add(new ColumnStyle(SizeType.Percent, 20F));

                    Panel p = GetBoardPanel(color);
                    int outSize = Convert.ToInt32((double)mainPanel.Height * 0.65);
                    p.Size = new Size(outSize / size, outSize / size);

                    chessBoard.Controls.Add(p, i, j);

                    color = (color == UserColor.cellWhite) ? UserColor.cellGreen : UserColor.cellWhite;
                }
                
                if(size % 2 == 0)
                    color = (color == UserColor.cellWhite) ? UserColor.cellGreen : UserColor.cellWhite;
            }

            chessBoard.ResumeLayout();
        }

        private void ClearKnight(Point pnt)
        {
            Panel panel = (Panel)chessBoard.GetControlFromPosition(pnt.X, pnt.Y);
            panel.BackgroundImage = Properties.Resources.visited; 
        }

        private void PositionKnight(Point pnt)
        {
            Panel panel = (Panel)chessBoard.GetControlFromPosition(pnt.X, pnt.Y);
            panel.BackgroundImage = Properties.Resources.knight;
        }

        private void SetPathFromFile(string fileName, List<Point> tour)
        {
            try
            {
                string strPath = File.ReadAllText(fileName);
                tour.Clear();

                string[] steps = strPath.Split(';');
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
                        MessageBox.Show(exc.Message);
                    }
                    catch (IndexOutOfRangeException exc)
                    {
                        MessageBox.Show(exc.Message);
                    }
                }
            }
            catch (IOException exc)
            {
                MessageBox.Show(exc.Message);
            }
        }

        private int GetBoardSize(List<Point> tour)
        {
            int size = 0;

            foreach (Point p in tour)
            {
                if(p.X > size)
                    size = p.X;

                if(p.Y > size)
                    size = p.Y;
            }

            return size + 1;
        }

        private void TourStep(List<Point> tour)
        {
            if(tour.Count > 1)
            {
                ClearKnight(tour[0]);
                tour.RemoveAt(0);
                PositionKnight(tour[0]);
            }
        }

        private void btnRun_Click(object sender, EventArgs e)
        {
            btnStep.Enabled = false;
            refreshTimer.Start();
        }

        private void btnStop_Click(object sender, EventArgs e)
        {
            btnStep.Enabled = true;
            refreshTimer.Stop();
        }

        private void btnStep_Click(object sender, EventArgs e)
        {
            TourStep(knightTour);
        }

        private void btnReset_Click(object sender, EventArgs e)
        {
            knightTour = new List<Point>(memKnightTour);
            CreateBoard(GetBoardSize(knightTour));
            PositionKnight(knightTour[0]);
        }

        private void btnLoad_Click(object sender, EventArgs e)
        {
            OpenFileDialog openFileDialog = new OpenFileDialog();

            if (openFileDialog.ShowDialog() == DialogResult.OK)
            {
                SetPathFromFile(openFileDialog.FileName, knightTour);
                CreateBoard(GetBoardSize(knightTour));
                PositionKnight(knightTour[0]);

                memKnightTour = new List<Point>(knightTour);
            }
        }

        private void refreshTimer_Tick(object sender, EventArgs e)
        {
            if(knightTour.Count <= 1)
            {
                refreshTimer.Stop();
            }
            else
            {
                TourStep(knightTour);
            }
        }

        private void speedTrackBar_Scroll(object sender, EventArgs e)
        {
            int diff = speedTrackBar.Maximum - speedTrackBar.Value;
            if (diff < 10)
                diff = 10;

            refreshTimer.Interval = diff;
        }
    }
}
