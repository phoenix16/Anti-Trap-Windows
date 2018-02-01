# Anti-Trap-Windows
This is a prototype of a car window that rolls down if an obstacle is detected in its path.
This prevents commonly occurring injuries caused by power windows.

Sample situations:
- The car driver engages the car's power windows to roll up without realizing that a passenger or child's hand is in a window's path.
- A pet's head is in the path of a car window rolling up.

To demonstate this idea, the window rim of a toy car is made touch sensitive by connecting it to a capacitive touch sensor using conducting copper tape.
An arduino controller simulates the window motion using a servo motor. When a user touches the window rim while the window is rolling up, the touch controller sends a "Roll Down" command to the arduino powered window.
