# MatrixTraversal
The program checks whether matrix is closed or not on assembly language.  
"Сlosed" means whether there exists such a passage on the extreme points of the matrix, which leads to the starting point.  
Program result below.  
![image](https://github.com/Chilibonitsu/MatrixTraversal/assets/86125427/80c7fd3c-b4e3-4790-9372-9721f9c2eda1)  
The program is written by working with bits of the array   
Shell is the extreme points of the matrix by columns and rows  
First the program finds the shell, then checks if there is a path from the initial point to the initial point by the shell  
Array represents input matrix  
Shell Left represents edge bits of the matrix by rows  
Shell Left and Right represents edge bits of the matrix by rows and columns  
Result (1 or 0) stands for pass through the matrix. If matrix has path from start to start through shell bits the result will be 1  
Matrix traversal order:  
Y stands for column  
X stands for row  
1. Y+1, to the right
2. X+1, Y+1, diagonally down and to the right
3. X+1, downwards
4. X+1, Y-1, diagonally down and to the left
5. Y-1, to the left
6. Y-1, X-1, diagonally up and to the left
7. X-1, upwards
8. Y+1, X-1, diagonally up and to the right

Some results below  
Note that when the result is 0, the start bit is 0 because the pass through the matrix does not end at the start bit.  
Also note that the output in the console corresponds to the standard data type assignment in assembler. The first bit in the first line on the right 
![image](https://github.com/Chilibonitsu/MatrixTraversal/assets/86125427/c7b736bb-4938-4b76-946a-76f9979ee8a5)  
![image](https://github.com/Chilibonitsu/MatrixTraversal/assets/86125427/8165b2d8-7d1e-458f-a552-68223fb2dee9)  

![image](https://github.com/Chilibonitsu/MatrixTraversal/assets/86125427/6a12edc4-6164-4881-bed4-655a1ee7e0cb)  
![image](https://github.com/Chilibonitsu/MatrixTraversal/assets/86125427/5565a17b-426e-4eaa-a6b2-abf9268b0347)  
![image](https://github.com/Chilibonitsu/MatrixTraversal/assets/86125427/35895392-fc35-4c37-9de7-e79d26a5ef25)  
![image](https://github.com/Chilibonitsu/MatrixTraversal/assets/86125427/0deba6aa-ce08-4740-bf8b-b701ad64c08c) 
![image](https://github.com/Chilibonitsu/MatrixTraversal/assets/86125427/2fa4a383-cfca-4ca7-84fc-9b94c7865705)  
![image](https://github.com/Chilibonitsu/MatrixTraversal/assets/86125427/5ae6ff18-b497-43bc-92e8-4af02a4f2928)  
![image](https://github.com/Chilibonitsu/MatrixTraversal/assets/86125427/c3b3f935-e6ca-4cdb-a14c-2eb98390e646)






