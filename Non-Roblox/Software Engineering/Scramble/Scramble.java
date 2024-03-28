package edu.unl.cse.soft160.conditionals;

import java.util.Scanner;

public class Scramble {
	public static void main(String... arguments) {

		Scanner scanner = new java.util.Scanner(System.in);

		System.out.print("Enter first value: ");
		int firstValue = Integer.parseInt(scanner.nextLine());

		System.out.print("Enter second value: ");
		int secondValue = Integer.parseInt(scanner.nextLine());

		System.out.print("Enter third value: ");
		int thirdValue = Integer.parseInt(scanner.nextLine());

		scanner.close();

		if (firstValue > secondValue) {
			if (secondValue > thirdValue) {
				System.out.println("The median is " + secondValue + ".");
			} else if (firstValue > thirdValue) {
				System.out.println("The median is " + thirdValue + ".");
			} else {
				System.out.println("The median is " + firstValue + ".");
			}
		} else if (firstValue < thirdValue) {
			if (secondValue < thirdValue) {
				System.out.println("The median is " + secondValue + ".");
			} else {
				System.out.println("The median is " + thirdValue + ".");
			}
		} else {
			System.out.println("The median is " + firstValue + ".");
		}
	}
}

