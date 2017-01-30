var[][] field;
var[][] map;
var mines;
    
class Minefield{
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
        
        
        this.field = new char[rows][cols];  // Create new minefield
        this.map = new char[rows][cols];    // Create the user's map
        this.mines = numMines;              // Store number of mines in field
        
        // Bury the mines
        for (int i = 0; i < this.mines; i++) {
            int row;
            int col;
            
            // Find a random location that does not yet contain a mine.
            do {
                row = random(rows);
                col = random(cols);
            } while (field[row][col] == 'M');
            
            field[row][col] = 'M';  // Place a mine at the random location
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
