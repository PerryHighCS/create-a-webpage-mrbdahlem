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
        
        char[][] map = field.getMap();
                
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
