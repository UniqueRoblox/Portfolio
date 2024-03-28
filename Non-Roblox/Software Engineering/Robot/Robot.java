package edu.unl.cse.soft160.tdd_homework;

import java.util.ArrayList;
import java.util.List;

public class Robot {
	public enum Mode {
		ENROUTE, RANDOM, SAMPLING,
	}

	public enum Action {
		TURN, GO_FORWARD, GO_BACKWARD, REPORT, SAMPLE, STOP,
	}

		
		Boolean lowBattery = (batteryLevel == 1 || batteryLevel == 2);
		
        List<Action> Actions = new ArrayList<Action>(); 
		
		if (batteryLevel == 0) {
			return Action.STOP;
		}

		if (!lowBattery) {
			if (pathBlocked == true) {
				if (mode == Mode.RANDOM) {
					Actions.add(Action.GO_BACKWARD);
				} else {
					Actions.add(Action.TURN);
				}
			}
			
			if (mode == Mode.RANDOM) {
				
				if (goalDistance >= 2) {
					Actions.add(Action.TURN);
				} else if (goalDistance == 1) {
					Actions.add(Action.GO_FORWARD);
				}
			}
			
			if (mode == Mode.ENROUTE) {
				if (goalDistance < 0) {
					Actions.add(Action.GO_BACKWARD);
				}
				if (goalDistance > 1 && memoryFull == false) {
					Actions.add(Action.GO_FORWARD);
				}
			}
			if (memoryFull == true) {
				Actions.add(Action.REPORT);
			}
		}

		if ((goalDistance == 0 ) && (lastActionTaken == Action.GO_FORWARD || lastActionTaken == Action.GO_BACKWARD)) {
			 Actions.add(Action.STOP); 
		 }
		
		if (!lowBattery) {
			if (lastActionTaken == Action.REPORT && mode == Mode.SAMPLING) {
				Actions.add(Action.TURN);
			}
		
			if (mode == Mode.SAMPLING && lastActionTaken == Action.SAMPLE) {
				//Actions.add(Action.REPORT);
				Actions.add(Action.REPORT);
			}
		}
		
		if (mode == Mode.SAMPLING && goalDistance == 0) {
			if (memoryFull == true) {
				if (!lowBattery) {
					Actions.add(Action.REPORT);
				} else {
					Actions.add(Action.STOP);
				}
				if (goalDistance > 0) {
					Actions.add(Action.TURN);
				}
				
			} else {
				Actions.add(Action.SAMPLE);
			}
		} else if (mode == Mode.SAMPLING){
			Actions.add(Action.STOP);
		}
		
		if (!lowBattery) {
			if ((lastActionTaken == Action.GO_BACKWARD || lastActionTaken == Action.GO_FORWARD) && Actions.size() != 1)  {
				Actions.add(lastActionTaken);
			}
		}

		
		if (Actions.size() > 1) {
			return Action.STOP;
		} else if (Actions.size() == 1) {
			return Actions.get(0);
		}
		
		if (!lowBattery) {
			if (goalDistance == -1) {
				return Action.GO_BACKWARD;
			} else if (goalDistance < 0){
				return Action.TURN;
			}
			if (goalDistance > 0) {
				return Action.GO_FORWARD;
			} else if (goalDistance < 0) {
				return Action.GO_BACKWARD;
			}
		}

		
		return Action.STOP;
	}
}
