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
using System.Reflection;

namespace Knight_tour
{
    public partial class MainGui : Form
    {
        List<List<Point>> allTours = new List<List<Point>>();
        int current_tour = 0;

        List <Point> memKnightTour = new List<Point>();
        List<Point> knightTour = new List<Point>();

        public MainGui()
        {
            InitializeComponent();
            this.SetStyle(ControlStyles.DoubleBuffer | ControlStyles.OptimizedDoubleBuffer, true);

            //CreateBoard(8);
            //PositionKnight(new Point(3, 3));
        }

        private Label GetBoardCellLabel(int n)
        {
            Label lbl = new Label
            {
                Dock = DockStyle.Fill,
                Font = new Font("Microsoft Sans Serif", 18F, FontStyle.Regular, GraphicsUnit.Point, ((byte)(0))),
                ForeColor = SystemColors.Control,
                Location = new Point(3, 0),
                Name = "",
                Size = new Size(50, 50),
                TabIndex = 0,
                Text = $"{n}",
                TextAlign = ContentAlignment.MiddleCenter
            };

            return lbl;
        }

        private PictureBox GetBoardCell(Color c)
        {
            PictureBox panel = new PictureBox
            {
                BackColor = c,
                Dock = DockStyle.Fill,
                Location = new Point(0, 0),
                Size = new Size(50, 50),
                Name = "",
                BackgroundImageLayout = ImageLayout.Zoom,
                //BorderStyle = BorderStyle.FixedSingle,
                Margin = new Padding(0),
            };

            return panel;
        }

        private void CreateBoard(int size)
        {
            chessBoard.Visible = false;
            chessBoard.SuspendLayout();
            chessBoard.CellBorderStyle = TableLayoutPanelCellBorderStyle.None;
            chessBoard.Controls.Clear();
            chessBoard.ColumnStyles.Clear();
            chessBoard.RowStyles.Clear();

            size++;

            chessBoard.ColumnCount = size;
            chessBoard.RowCount = size;

            for (int i = 0; i < size; i++)
            {
                chessBoard.ColumnStyles.Add(new ColumnStyle(SizeType.AutoSize));

                for (int j = 0; j < size; j++)
                {
                   chessBoard.RowStyles.Add(new RowStyle(SizeType.AutoSize));
                }
            }

            int outSize = Math.Min(mainPanel.Height, mainPanel.Width);
            outSize = Convert.ToInt32((double)outSize * 0.8);
            Size cellSize = new Size(outSize / size, outSize / size);

            for (int i = 1; i < size; i++)
            {
                var lbl = GetBoardCellLabel(i - 1);
                lbl.Size = cellSize;
                chessBoard.Controls.Add(lbl, i, 0);

                lbl = GetBoardCellLabel(i - 1);
                lbl.Size = cellSize;
                chessBoard.Controls.Add(lbl, 0, i);
            }

            Color color = UserColor.cellGreen;
            for (int i = 1; i < size; i++)
            {
                for (int j = 1; j < size; j++)
                {
                    var p = GetBoardCell(color);
                    p.Size = cellSize;
                    chessBoard.Controls.Add(p, i, j);

                    color = (color == UserColor.cellWhite) ? UserColor.cellGreen : UserColor.cellWhite;
                }

                if ((size - 1) % 2 == 0)
                    color = (color == UserColor.cellWhite) ? UserColor.cellGreen : UserColor.cellWhite;
            }

            chessBoard.Size = new Size(500, 500);
            chessBoard.ResumeLayout();
            chessBoard.Visible = true;
        }

        private void ResetBoard()
        {
            foreach(Control ctrl in chessBoard.Controls)
            {
                ctrl.BackgroundImage = null;
            }
        }

        private void ClearKnight(Point pnt)
        {
            Control ctrl = chessBoard.GetControlFromPosition(pnt.X + 1, pnt.Y + 1);
            ctrl.BackgroundImage = Properties.Resources.visited; 
        }

        private void PositionKnight(Point pnt)
        {
            Control ctrl = chessBoard.GetControlFromPosition(pnt.X + 1, pnt.Y + 1);
            ctrl.BackgroundImage = Properties.Resources.knight;
        }

        private void SetTourFromLine(string line, List<Point> tour)
        {
            tour.Clear();

            string[] steps = line.Split(';');
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

        private void SetPathFromFile(string fileName)
        {
            try
            {
                string[] strTour = File.ReadAllLines(fileName);

                allTours.Clear();

                foreach(string line in strTour)
                {
                    List<Point> t = new List<Point>();
                    SetTourFromLine(line, t);
                    allTours.Add(t);
                }

                if(allTours.Count > 0)
                {
                    current_tour = 0;
                    //knightTour = new List<Point>(allTours[0]);
                    //memKnightTour = new List<Point>(allTours[0]);

                    knightTour = mergeAllTours();
                    memKnightTour = new List<Point>(knightTour);

                    allTours.Clear();
                    allTours.Add(knightTour);
                }
            }
            catch (IOException exc)
            {
                MessageBox.Show(exc.Message);
            }
        }

        private int GetBoardSize()
        {
            int max = 0;
            foreach(var t in allTours)
            {
                int k = GetBoardSize(t);
                if(k > max)
                    max = k;
            }

            return max;
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

                UpdateStepLabel();
            }
            else
            {
                if(allTours.Count > (current_tour + 1))
                {
                    current_tour++;
                    knightTour = new List<Point>(allTours[current_tour]);
                    memKnightTour = new List<Point>(allTours[current_tour]);

                    ResetBoard();
                    PositionKnight(knightTour[0]);
                    UpdateStepLabel();
                }
            }
        }

        private void UpdateStepLabel()
        {
            lblStepCnt.Text = $"{(memKnightTour.Count - knightTour.Count)}/{memKnightTour.Count}";
            lblCellValue.Text = $"({knightTour[0].X},{knightTour[0].Y})";
        }

        private void btnRun_Click(object sender, EventArgs e)
        {
            if (memKnightTour.Count == 0)
            {
                LoadTourFromFile();
            }
            else 
            {
                btnStep.Enabled = false;
                refreshTimer.Start();
            }
        }

        private void btnStop_Click(object sender, EventArgs e)
        {
            if (memKnightTour.Count == 0)
                return;

            btnStep.Enabled = true;
            refreshTimer.Stop();
        }

        private void btnStep_Click(object sender, EventArgs e)
        {
            if (memKnightTour.Count == 0)
                return;

            TourStep(knightTour);
        }

        private void btnReset_Click(object sender, EventArgs e)
        {
            if (memKnightTour.Count == 0)
                return;

            knightTour = new List<Point>(memKnightTour);
            ResetBoard();
            PositionKnight(knightTour[0]);
            UpdateStepLabel();
        }

        private void LoadTourFromFile()
        {
            OpenFileDialog openFileDialog = new OpenFileDialog();

            if (openFileDialog.ShowDialog() == DialogResult.OK)
            {
                SetPathFromFile(openFileDialog.FileName);
                CreateBoard(GetBoardSize());
                PositionKnight(knightTour[0]);

                memKnightTour = new List<Point>(knightTour);
                UpdateStepLabel();
            }
        }


        private void openToolStripMenuItem_Click(object sender, EventArgs e)
        {
            LoadTourFromFile();
        }

        private void refreshTimer_Tick(object sender, EventArgs e)
        {
            if ((current_tour == allTours.Count - 1) && knightTour.Count <= 1)
            {
                refreshTimer.Stop();
            }
            else
            {
                TourStep(knightTour);
            }
        }

        private void ChessBoardZoom(int dir)
        {
            double k = 0.5;
            double step = (dir < 0) ? (1 - k) : (1 + k);

            chessBoard.Visible = false;
            chessBoard.SuspendLayout();

            foreach (Control control in chessBoard.Controls)
            {
                Size sz = control.Size;
                int x = Convert.ToInt32((double)sz.Width * step);
                sz.Width = x;
                sz.Height = x;
                control.Size = sz;

                try
                {
                    Label lbl = control as Label;

                    if(dir > 0)
                        lbl.Font = Font = new Font("Microsoft Sans Serif", 18F, FontStyle.Regular, GraphicsUnit.Point, ((byte)(0)));
                    else
                        lbl.Font = Font = new Font("Microsoft Sans Serif", 10F, FontStyle.Regular, GraphicsUnit.Point, ((byte)(0)));
                }
                catch(Exception) { }
            }

            chessBoard.ResumeLayout();
            chessBoard.Visible = true;
        }

        private void btnZoomIn_Click(object sender, EventArgs e)
        {
            ChessBoardZoom(1);
        }

        private void btnZoomOut_Click(object sender, EventArgs e)
        {
            ChessBoardZoom(-1);
        }

        private void btnSpeedUp_Click(object sender, EventArgs e)
        {
            int spd = refreshTimer.Interval;
            spd -= 100;
            if (spd < 10)
                spd = 10;

            refreshTimer.Interval = spd;
        }

        private void btnSpeedDn_Click(object sender, EventArgs e)
        {
            int spd = refreshTimer.Interval;

            spd += 100;
            if (spd > 1000)
                spd = 1000;

            refreshTimer.Interval = spd;
        }

        private void exitToolStripMenuItem_Click(object sender, EventArgs e)
        {
            this.Close();
        }

        private void aboutToolStripMenuItem_Click(object sender, EventArgs e)
        {
            Version version = Assembly.GetEntryAssembly().GetName().Version;
            MessageBox.Show($"Version: {version}", "About", MessageBoxButtons.OK, MessageBoxIcon.Information);
        }

        private List<Point> mergeAllTours()
        {
            List<Point> ans = new List<Point>();
            if (allTours.Count > 0) 
            {
                ans = new List<Point>(allTours[0]);

                for (int i = 1; i < allTours.Count; i++)
                {
                    int m = allTours[i].Count;
                    int n = (i > 0) ? allTours[i - 1].Count : ans.Count;

                    if (m > n)
                    {
                        ans.AddRange(allTours[i].GetRange(n, (m - n)));
                    }
                    else
                    {
                        int j = 0;

                        while (j < m && j < n && allTours[i-1][j] == allTours[i][j])
                            j++;

                        ans.Add(allTours[i][j - 1]);
                        ans.AddRange(allTours[i].GetRange(j, (m - j)));
                    }
                }
            }


            return ans;
        }
    }
}
