#Q1 Fix all the syntax and logical errors in the given source code 
#add comments to explain your reasoning

# This program gets three test scores and displays their average.  It congratulates the user if the 
# average is a high score. The high score variable holds the value that is considered a high score.

# Initial: HIGH_SCORE = 95
high_score = 95 # Python case sensitive - needs to match in all places the variable is called (changed to lower case to maintain uniformity)
 
# Get the test scores.
test1 = input('Enter the score for test 1: ')
test2 = input('Enter the score for test 2: ')
test3 = input('Enter the score for test 3: ') # initially missing variable for test3 - added
# Calculate the average test score.
# Initial: average = test1 + test2 + test3 / 3 --> TypeError
average = (int(test1) + int(test2) + int(test3)) / 3 # inputs are str type --> convert to int; add parenthesis for order of operations
# Print the average.
# Initial: print('The average score is', average) --> TypeError
print('The average score is', str(average)) # convert int to str type
# If the average is a high score,
# congratulate the user.
if average >= high_score:
    print('Congratulations!')
print('That is a great average!')

#Q2
#The area of a rectangle is the rectangle’s length times its width. Write a program that asks for the length and width of two rectangles and prints to the user the area of both rectangles. 
# Function for area
def area(l, w):
    return l*w
# Ask for lenths and widths
length1, width1 = input("Enter the length and width of the first rectangle, separated by one space: ").split()
length2, width2 = input("Enter the length and width of the second rectangle, separated by one space: ").split()
# Print areas
print("Area of the first rectangle =", str(area(int(length1), int(width1))))
print("Area of the second rectangle =", str(area(int(length2), int(width2))))

#Q3 
#Ask a user to enter their first name and their age and assign it to the variables name and age. 
#The variable name should be a string and the variable age should be an int.  
name = input("What is your first name? ")
age = int(input("What is your age? ")) # ask for age and convert to int at same time

#Using the variables name and age, print a message to the user stating something along the lines of:
# "Happy birthday, name!  You are age years old today!"
print(f'Happy birthday, {name}! You are {str(age)} years old today!')