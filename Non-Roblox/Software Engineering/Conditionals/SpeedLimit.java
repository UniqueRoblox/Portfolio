package edu.unl.cse.soft160.conditionals;

import java.util.Scanner;

		// "Unless otherwise marked, a street's speed limit in a particular city is
		// determined by type of street.
		// A residential street has a speed limit of 40 km/h. All other streets have a
		// speed limit of 70 km/h.
		// The exception to this rule is that a school zone has a speed limit of 25
		// km/h, regardless of the type of street.
		// Given a car's speed, the type of street, and whether it's in a school zone,
		// print 'Speeding' followed by a newline
		// if the car exceeds the applicable speed limit. Otherwise, print 'Safe'
		// followed by a newline.
		// You may assume that the car's speed will never be negative."

public class SpeedLimit {
	public static void main(String... arguments) {

		Scanner scanner = new Scanner(System.in);
		System.out.print("What is the car's speed (in km/h)? ");
		System.out.print("Is the car on a residential street (yes/no)? ");
		System.out.print("Is the car in a school zone (yes/no)? ");

		double speed = Double.parseDouble(scanner.nextLine());
		boolean residentialZone = scanner.nextLine().matches("[Yy].*");
		boolean schoolZone = scanner.nextLine().matches("[Yy].*");

		scanner.close();

		double speedLimit = 70;

		if (schoolZone) {
			speedLimit = 25;
		} else if (residentialZone) {
			speedLimit = 40;
		}

		if (speed > speedLimit) {
			System.out.println("Speeding");
		} else {
			System.out.println("Safe");
		}
	}
}
