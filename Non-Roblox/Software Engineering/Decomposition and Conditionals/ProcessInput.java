package edu.unl.cse.soft160.decomposition_and_conditionals;

import java.util.Scanner;

public class ProcessInput {
	private static enum State {
		EMPTY, DECIMAL, NUMERIC,
	}

	private static enum Classification {
		FLOAT, INTEGER, NAN,
	}

	public static ProcessInput.Classification EmptyValue(char letter) {
		if (Character.isDigit(letter)) {
			return Classification.INTEGER;
		} else if (letter == ".".charAt(0)) {
			return Classification.FLOAT;
		} else {
			return Classification.NAN;
		}
	}

	public static ProcessInput.Classification DecimalValue(char letter) {
		if (Character.isDigit(letter) || letter == "f".charAt(0) || letter == "d".charAt(0)) {
			return Classification.FLOAT;
		} else {
			return Classification.NAN;
		}
	}

	public static ProcessInput.Classification NumValue(char letter) {
		if (letter == "f".charAt(0) || letter == "d".charAt(0) || letter == ".".charAt(0)) {
			return Classification.FLOAT;
		} else {
			return Classification.INTEGER;
		}
	}

	public static void main(String... arguments) {
		Scanner scanner = new Scanner(System.in);

		System.out.print("Enter the current state: ");
		String inputState = scanner.nextLine();

		System.out.print("Enter the next character: ");
		String inputCharacter = scanner.nextLine();

		char nextCharacter = inputCharacter.charAt(0);
		ProcessInput.State userState = ProcessInput.State.valueOf(inputState.toUpperCase());

		scanner.close();

		ProcessInput.Classification endState;

		if (userState == State.EMPTY) {

			endState = EmptyValue(nextCharacter);

		} else if (userState == State.DECIMAL) {

			endState = DecimalValue(nextCharacter);

		} else if (userState == State.NUMERIC) {

			endState = NumValue(nextCharacter);

		} else {
			System.out.print("Not a valid type");
			return;
		}

		System.out.println("Classification: " + endState);
	}
}
