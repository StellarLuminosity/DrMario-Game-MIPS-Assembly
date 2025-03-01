# Dr. Mario - Assembly Game Design  

## Overview  
This project is a **MIPS assembly** recreation of the classic Nintendo **Dr. Mario** game, developed for the **CSC258: Computer Organization** course using the Saturn MIPS simulator. Players are able to control falling **colored capsules**, rotate and position them to match **four or more** of the same color in a row or column to eliminate viruses.  

## Features  
- Custom capsule environment 
- Capsule movement and rotation  
- Random virus generation  
- Pixel collision detection
- Virus elimination system
- Score tracking and display 
- Sound effects on collision, pixel elimination, and game termination 

## Controls  
- **W** - Rotate capsule  
- **A** - Move left  
- **S** - Drop down  
- **D** - Move right  
- **P** - Pause game 
- **Q** - Quit game  

## Technical Details  
- **Display Configuration:**  
  - Unit width: 2 pixels  
  - Unit height: 2 pixels  
  - Display width: 64 pixels  
  - Display height: 64 pixels  
  - Base Address: `0x10008000`  
- **Game Components:**  
  - **Bottle System** – Implements game boundaries & collision detection  
  - **Capsule Management** – Handles capsule generation, movement & rotation  
  - **Virus System** – Manages virus placement & elimination  
  - **Color Matching** – Detects and removes matching sequences  
  - **Physics** – Simulates falling capsules and chain reactions  
  - **Sound System** – Provides audio feedback for game events  

## How to Run  
1. **Download & open the [Saturn MIPS Simulator](https://github.com/1whatleytay/saturn/releases)**  
2. **Load files** `DrMario.asm`  
3. **Configure the Bitmap Display** with:  
   - **Unit Width:** 2  
   - **Unit Height:** 2  
   - **Display Width:** 64  
   - **Display Height:** 64  
   - **Base Address:** `0x10008000`  
4. **Run the program** and play!  

## Academic Context  
This project was developed as part of **CSC258H1: Computer Organization** at the **University of Toronto**. It demonstrates core assembly programming concepts:  
- **Machine Language Programming** – Direct MIPS assembly implementation  
- **Memory Management** – Tracking game state in limited registers  
- **Bitmap Manipulation** – Rendering capsules & viruses in a grid  
- **Input Handling** – Processing player keystrokes  
- **Game Loop Implementation** – Handling movement, physics & logic  

## License  
This project is for **educational purposes only**. **Dr. Mario** is a **trademark of Nintendo**.  
