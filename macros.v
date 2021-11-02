//This file defines several macros which are defined globally throughout the project. Their values are specified here
//and their purpose is to improve code readability


//Letter to numerical equivalents for the Seven-Segment Displays
`define SSD_F 11
`define SSD_A 12
`define SSD_I 13
`define SSD_L 14
`define SSD_E 15
`define SSD_D 16
`define SSD_OFF 17

//Numerical equivalents of the top-level system states.
`define STATE_IDLE 3'd0
`define STATE_PREP 3'd1
`define STATE_TEST 3'd2
`define STATE_RESULT_OK 3'd3
`define STATE_RESULT_FAIL 3'd4

//LED display for the different states.
`define FAIL 11111
`define IDLE 11112
`define LED_BLANK 11113

//Time-related quantities, including the maximum user reaction time (TEST_TIMEOUT), the maximum amount of time before returning
// to STATE_IDLE (RESULT_TIMEOUT) and the minimum time required for the countdown (PREP_TIMEOUT).
`define TEST_TIMEOUT 10_000
`define RESULT_TIMEOUT 10_000
`define PREP_TIMEOUT_MIN 3_000

//Quantities used in the generation of random wait times, including a lower bound (RNG_LOWER_BOUND), default (RNG_DEFAULT) and
//the modulo divisor (RNG_MODULO_DIVISOR) which ensures the random wait is always between 1 and 5 seconds.
`define RNG_LOWER_BOUND 14'd1_000
`define RNG_MODULO_DIVISOR 4_000
`define RNG_DEFAULT 14'd2_500