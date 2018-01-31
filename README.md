# Anti-Trap-Windows
A prototype of a car window that detects obstacles in its path and automatically rolls down.

This prevents commonly occurring injuries caused by power windows. Sample situations:
- The car driver engages the car's power windows to roll up without realizing that a passenger or child's hand is in a window's path.
- A pet has its head outside the car window while it engages the roll-up button on the car window.

To demonstate this idea, a capacitive touch sensor is connected to the rim of a toy car window using conducting copper tape.
An arduino controller simulates the window motion using a servo motor. When a user touches the window rim, the touch controller sends a "Roll Down" command to the arduino powered window.
