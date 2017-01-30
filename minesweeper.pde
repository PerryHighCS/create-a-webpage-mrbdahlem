void setup() {
        size(400, 400);         // Set the default size of the display window
        setDifficulty();
        
        frame.setResizable(true);
    }
    
    /**
     * Update the display window
     */
 void draw() {
        if (gameOver)
            background(255,0,0);  // Set the window background to red
        else
            background(0);        // Set the window background to black
        
        calcSizes();    // Calculate the size of the cells to fit the window
        
        var map = field.getMap();
                
        for (int j = 0; j < rows; j++) {        // For every cell on the map
            for (int i = 0; i < cols; i++) {
                // Calculate the top-left corner of the cell
                int x = (i * cellSizeX) + offsetX;
                int y = (j * cellSizeY) + offsetY;
                
                // Default to a white cell with a white outline
                fill(255);
                stroke(255);
                
                if(gameOver) {
                    stroke(255, 0, 0);  // if the game is over, draw red lines
                }
                
                if (map[j][i] == 0) {
                    fill(0);         // Fill unknown squares with black
                }
                else if (map[j][i] == '.') {
                    fill(255);        // Fill mapped squares with white
                }
                else if (map[j][i] == '*') {
                    fill(255, 0, 0);  // Fill mine squares with red
                }
                else if (map[j][i] == '?') {
                    fill(255, 255, 0);// Fill flagged squares with yellow
                }
                else if (map[j][i] == '@') {
                    fill(128);        // Fill found mines with grwy
                }
                                   
                rect(x, y, cellSizeX, cellSizeY);  // Draw the square
                
                // If the cell contains a number, mine, or flag, display
                // it in the middle of the cell.
                if ("12345678*?@".contains(map[j][i] + "")) {
                    fill(0);
                    textAlign(CENTER, CENTER);
                    textSize(cellSizeY - 4);
                    if (map[j][i] == '@') {  // Display '@' as mines
                        text("*", x + cellSizeX / 2, y + cellSizeY / 2);
                    }
                    else {                   // Display everything else as is
                        text(map[j][i] + "", x + cellSizeX / 2,
                             y + cellSizeY / 2);
                    }
                }
                
            }
        }
    }
    
    /**
     * Display an option window to allow the user to choose game difficulty, then
     * set up the minefield.
     */
 void setDifficulty() {
        gameOver = false;
        
        // Game difficulty labels
        final String e = "Easy";
        final String m = "Medium";
        final String h = "Hard";
        
        // Let the user choose the game difficulty
        Object[] difficulties = {e, m, h};
        Object selection = JOptionPane.showInputDialog(null, "Choose your difficulty.", "Minefield",
                                                       JOptionPane.QUESTION_MESSAGE, null,
                                                       difficulties, difficulties[1]);
        
        if (selection == null) {  // If the user pressed cancel
            System.exit(0);       // End the game
        }
        
        switch ((String)selection) {
        case e: // Easy
            rows = 10;
            cols = 10;
            mines = 10;
            break;
        case m: // Medium
            rows = 15;
            cols = 15;
            mines = 40;
            break;
        case h: // Hard
            rows = 25;
            cols = 25;
            mines = 140;
            break;
        }
        
        frame.setTitle(selection + " Minefield");   // Update the window's title
        field = new Minefield(rows, cols, mines);   // Fill the field with mines
    }
    
    /**
     * Determine the cell sizes and their location based on the display size.
     */
 void calcSizes() {
        // Determine how big a cell should be
        cellSizeX = (width - 1) / cols;
        cellSizeY = (height - 1) / rows;
        
        // Center the minefield in the available space
        int realWidth = cellSizeX * cols;
        int realHeight = cellSizeY * rows;
        offsetX = (width - realWidth) / 2;
        offsetY = (height - realHeight) / 2;    
    }
    
    /**
     * When the user presses the mouse button, make a move.  If the right button
     * is pressed, flag the space.  If the left button is pressed, check that
     * square for a mine.
     */
 void mousePressed() {
        int col = (mouseX - offsetX) / cellSizeX;
        int row = (mouseY - offsetY) / cellSizeY;
        
        if (mouseButton == LEFT) {
            if (gameOver) {
                setDifficulty();    
            }
            else if (field.sweep(row,col)) {  // If the user clicks on a mine
               field.showMines();             // Show all the mines and end the game.
               gameOver = true;
            }
        }
        else if (mouseButton == RIGHT){       // If the user presses the right button
            field.flag(row,col);              // flag the cell as a possible mine
        }
    }
    

    
class Minefield{
    var field;
    var map;
    var mines;
    /**
     * Create the minefield and bury the mines.  The field is a rectangular map with a size of
     * rows cells vertically and cols cells horizontally.  The cells will be either empty or
     * contain a mine after creation.  There will be numMines mines hidden in the field.
     * 
     * @param rows      the number of rows in the minefield (rows > 0)
     * @param cols      the number of columns in the minefield (cols > 0)
     * @param numMines  the number of mines to place in the minefield (0 < mines <= (rows * cols))
     */
    public Minefield(int rows, int cols, int numMines) {
        
        
        this.field = new int[rows][cols];  // Create new minefield
        this.map = new int[rows][cols];    // Create the user's map
        this.mines = numMines;              // Store number of mines in field
        
        // Bury the mines
        for (int i = 0; i < this.mines; i++) {
            int row;
            int col;
            
            // Find a random location that does not yet contain a mine.
            do {
                row = random(rows);
                col = random(cols);
            } while (field[row][col] == (int)'M');
            
            field[row][col] = (int)'M';  // Place a mine at the random location
        }
        
        countMines();
    }
    
    public void countMines() {
        for (int i = 0; i < field.length; i++) {
            for (int j = 0; j < field[i].length; j++) {
                if (field[i][j] != 'M') {
                    int numSurrounding = countSurrounding(i, j);
                    
                    if (numSurrounding > 0) {
                        field[i][j] = (char)(numSurrounding + '0');
                    }
                }
            }
        }
    }
    
    private int countSurrounding(int row, int col) {
        int numSurrounding = 0;
        for (int i = row - 1; i <= row + 1; i++) {
            for (int j = col - 1; j <= col + 1; j++) {
                if (((i != row) || (j != col)) && isMine(i, j)) {
                    numSurrounding++;
                }
            }
        }
        return numSurrounding;
    }
    
    private boolean isMine(int row, int col) {
        if ((row >= 0 && row < field.length) &&
            (col >= 0 && col < field[row].length) &&
            field[row][col] == 'M') {
            return true;
        }
        return false;
    }
    
    /**
     * Accessor for the user's map of the minefield.
     * <em>Note: do not modify the map provided.  Doing so could lead to
     * instability</em>
     * Numbers in a cell represent the number of mines in adjacent cells.  An 
     * '*' represents a mine that has exploded.  A '.' represents a clear cell.
     * An 'M' represents a known mine.  An unknown cell is represented by
     * the value 0.
     * 
     * @return a char array representing the user's view of the minefield
     */
    public char[][] getMap() {
        return map;
    }
    
    /**
    * Updates the map matrix and reports success or failure whenever the user
    * makes a move in the game.
    * 
    * @param row the row of the location on the map to check for mines
    * @param col the column of the location on the map to check for mines
    * 
    * @return true if the location checked contains a mine, false if not
    */
    public boolean sweep(int row, int col) {
        // Make sure we are checking a valid location
        if (row < 0 || row >= field.length ||
            col < 0 || col >= field[row].length) {
            return false;
        }
        
        if(field[row][col] == 'M') { // If the cell is a mine,
            map[row][col] = '*';     // represent it in the map as *
            return true;             // The sweep found a mine
        }
        
        if ("123456789".contains(field[row][col]+"")) { // If the cell contains a number,
            map[row][col] = field[row][col];            //show the number on the map
            return false; // The sweep didn't find a mine
        }
        
        if(map[row][col] == '.') { // If the cell has already been mapped,
            return false;          // there isn't a mine there
        }
        
        map[row][col] = '.';       // Mark the cell as mapped

        // Recursively sweep all adjacent cells
        for (int x = -1; x <= 1; x++) {
            for (int y = -1; y <=1; y++) {
                sweep(row + y, col + x);
            }
        }
        
        return false; // The sweep didn't find a mine at this location
    }
    
    public void flag(int row, int col) {
        map[row][col] = '?';
    }
    
    /**
     * Display all of the mines on the map.
     */
    public void showMines() {
        for (int row = 0; row < field.length; row++) {
            for (int col = 0; col < field[row].length; col++) {
                if (field[row][col] == 'M') {
                    if (map[row][col] == '?') {
                        map[row][col] = '@';
                    }
                    else {
                        map[row][col] = '*';
                    }
                }
            }
        }
    }
