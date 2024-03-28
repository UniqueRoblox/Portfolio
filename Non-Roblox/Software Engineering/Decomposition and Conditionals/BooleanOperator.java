import java.util.Scanner;

import javax.sound.sampled.BooleanControl;

public class BooleanOperator {
	private static enum TruthValue {
		TRUE, FALSE, UNKNOWN,
	}

	public static void main(String... arguments) {
		Scanner scanner = new Scanner(System.in);

		String boolOne = userInputOne(scanner);

		String boolTwo = userInputTwo(scanner);
		
		scanner.close();

		BooleanOperator.TruthValue boolValueOne;
		BooleanOperator.TruthValue boolValueTwo;

		try {
			boolValueOne = BooleanOperator.TruthValue.valueOf(boolOne.toUpperCase());
			boolValueTwo = BooleanOperator.TruthValue.valueOf(boolTwo.toUpperCase());
		} catch (Exception e) {
			System.out.println("Truth value must be one of TRUE, FALSE, or UNKNOWN.");
			return;
		}

		BooleanOperator.TruthValue result = norTest(boolValueOne, boolValueTwo);

		System.out.println("The NOR value of " + boolValueOne + " and " + boolValueTwo + " is " + result + ".");
	}

	public static String userInputTwo(Scanner scanner) {
		System.out.print("Enter truth value of operand 2: ");
		String boolTwo = scanner.nextLine();
		return boolTwo;
	}

	public static String userInputOne(Scanner scanner) {
		System.out.print("Enter truth value of operand 1: ");
		String boolOne = scanner.nextLine();
		return boolOne;
	}

	public static BooleanOperator.TruthValue norTest(BooleanOperator.TruthValue boolValueOne,
			BooleanOperator.TruthValue boolValueTwo) {
		BooleanOperator.TruthValue result = TruthValue.FALSE;;
		if (boolValueOne == TruthValue.FALSE && boolValueTwo == TruthValue.FALSE) {
			result = TruthValue.TRUE;
		} else if (boolValueOne == TruthValue.UNKNOWN && boolValueTwo != TruthValue.TRUE
				|| boolValueTwo == TruthValue.UNKNOWN && boolValueOne != TruthValue.TRUE) {
			result = TruthValue.UNKNOWN;
		}
		return result;
	}
}
