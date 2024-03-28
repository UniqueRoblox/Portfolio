package edu.unl.cse.soft160.conditionals;

import java.util.Scanner;

public class Caucus {
	public static void main(String... arguments) {
		Scanner scanner = new Scanner(System.in);

		System.out.print("Is today a caucus day (yes/no)? ");

		boolean isCaucusDay = scanner.nextLine().matches("[Yy].*");

		System.out.print("Is the precinct report a correctly-formatted electronic report (yes/no)? ");

		boolean isCorrectlyFormattedReport = scanner.nextLine().matches("[Yy].*");

		System.out.print("Is the precinct report a telephoned report (yes/no)? ");

		boolean isTelephonedReport = scanner.nextLine().matches("[Yy].*");

		scanner.close();

		if (!isTelephonedReport) {
			if (isCaucusDay) {
				if (!isTelephonedReport) {
					if (!isCorrectlyFormattedReport) {
						System.out.println("Precinct report rejected");
						return;
					}
				}

				if (isTelephonedReport && isCorrectlyFormattedReport) {
					System.out.println("Precinct report rejected");
					return;
				}
			} else {
				System.out.println("Precinct report rejected");
				return;
			}
		}

		if (!isCaucusDay) {
			System.out.println("Precinct report rejected");
			return;
		}

		System.out.println("Precinct report accepted");
	}
}
