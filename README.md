# Anti-Trap-Windows
This is a prototype of a car window that rolls down if an obstacle is detected in its path.
This prevents commonly occurring injuries caused by power windows.

Sample situations:
- The car driver engages the car's power windows to roll up without realizing that a passenger or child's hand is in a window's path.
- A pet's head is in the path of a car window rolling up.

Implementation: 
- Make the window of a toy car touch sensitive by lining the rim with a conducting material, such as a piece of copper tape.
- Connect a capacitive touch sensor's electrodes to the car's window rim.
- Simulate the motion of the car window using a servo motor attached to a movable arm. Control the window motion using an arduino controller. The rotary motion of the servo motor is converted to the translation motion of the car window using a simple gear.
- When a user touches the window rim while the window is rolling up, send a "Roll Down" or "Stop" command to the rolling window.
