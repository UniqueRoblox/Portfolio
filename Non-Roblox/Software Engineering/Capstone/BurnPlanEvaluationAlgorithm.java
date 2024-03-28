package edu.unl.cse.soft160.burnplan;

import java.time.LocalDate;
import java.time.LocalTime;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.List;

/*
 * Acceptable (conditions are somewhat favorable and supplies meet minimum
 * requirements), Desired (conditions are highly favorable and supplies meet
 * minimum requirements), Burning is prohibited (red flag conditions prohibit
 * burning OR there is a ban on outdoor burning), Not recommended due to
 * temperature (conditions are unfavorable due to temperature forecast), Not
 * recommended due to wind (conditions are unfavorable due to wind forecast),
 * Not recommended due to other conditions (conditions or supplies do not meet
 * minimum requirements), Indeterminate (too little data to make a
 * determination).
 */

public class BurnPlanEvaluationAlgorithm {
	static List<Tools> requiredTools;
	static int toolsCheck = 0;

	public static void toolSetUp() {
		Tools Tool1 = new Tools("Dozer", 1, 0, "None");
		Tools Tool2 = new Tools("BackPack Pump", 1, 0, "None");
		Tools Tool3 = new Tools("Rakes", 1, 10, "Acers");
		Tools Tool4 = new Tools("Drip Torch", 1, 100, "Acers");
		Tools Tool5 = new Tools("Fire Starting Fuel", 1, 10, "Acers");
		Tools Tool6 = new Tools("Pumper", 1, 80, "Acers");

		requiredTools.add(Tool1);
		requiredTools.add(Tool2);
		requiredTools.add(Tool3);
		requiredTools.add(Tool4);
		requiredTools.add(Tool5);
		requiredTools.add(Tool6);
	}

	public static BurnDetermination evaluate(BurnPlan burnPlan) {
		// Double coldestTemp = observations.get(0).getMeasurement();

		toolsCheck = 0;

		requiredTools = new ArrayList<Tools>();
		Boolean favoredWeather = true;

		Weather weather = burnPlan.getWeather();

		LocalDate dateOfBurn = burnPlan.getBurnDate();
		LocalDate currentDate = burnPlan.getCurrentDate();
		toolSetUp();
		requieredToolCheck(burnPlan);

		if (burnPlan.getBurnBan() == true) {
			return BurnDetermination.BURNING_PROHIBITED;
		}

		if (toolsCheck != requiredTools.size()) {
			return BurnDetermination.NOT_RECOMMENDED_OTHER;
		}

		if (weather == null) {
			return BurnDetermination.INDETERMINATE;
		}

		if (ChronoUnit.DAYS.between(currentDate, dateOfBurn) > 5
				|| ChronoUnit.DAYS.between(currentDate, dateOfBurn) < 2) {
			return BurnDetermination.NOT_RECOMMENDED_OTHER;
		}

		if (weather.getWeatherOnBurnDate() == "Cold Front") {
			return BurnDetermination.NOT_RECOMMENDED_OTHER;
		}

		if (weather.getChanceOfRain() > 50) {
			if (weather.getRainAmount() > 10) {
				favoredWeather = false;
			}
			if (burnPlan.getBurnType() == BurnType.HEAVY) {
				return BurnDetermination.NOT_RECOMMENDED_OTHER;
			}
		}

		int acceptableCount = 0;

		// Midmorning to Late Afternoon shall be considered to be the hours between
		// 10:00 AM and 4:00 PM.
		// Midday to Late Afternoon shall be considered to be the hours between noon and
		// 4:00 PM.
		LocalTime morningTime = LocalTime.parse("10:00");
		LocalTime lateAfternoonTime = LocalTime.parse("16:00");
		LocalTime midDayTime = LocalTime.parse("12:00");

		if (burnPlan.getFireType() == "Blacklines") {
			if (weather.getTempature() < 35 || weather.getTempature() > 65) {
				return BurnDetermination.NOT_RECOMMENDED_TEMPERATURE;
			} else if (weather.getTempature() >= 40 && weather.getTempature() <= 60)
				;

			else {
				acceptableCount++;
			}

			if (weather.getWindSpeed() < 0 || weather.getWindSpeed() > 10) {
				return BurnDetermination.NOT_RECOMMENDED_WIND;
			} else if (weather.getWindSpeed() >= 0 && weather.getWindSpeed() <= 8)
				;
			else {
				acceptableCount++;
			}

			if (weather.getHumidity() < 30 || weather.getHumidity() > 65) {
				return BurnDetermination.NOT_RECOMMENDED_OTHER;
			} else if (weather.getTempature() >= 40 && weather.getTempature() <= 60)
				;
			else {
				acceptableCount++;
			}

			if (burnPlan.getCondition() == "Volatile") {
				if (burnPlan.getWidth() != 100) {
					return BurnDetermination.NOT_RECOMMENDED_OTHER;
				}
			} else if (burnPlan.getCondition() == "Non Volatile") {
				if (burnPlan.getWidth() != 500) {
					return BurnDetermination.NOT_RECOMMENDED_OTHER;
				}
			} else {
				return BurnDetermination.INDETERMINATE;
			}
			if (burnPlan.getBurnTime().isBefore(morningTime) || burnPlan.getBurnTime().isAfter(lateAfternoonTime)) {
				return BurnDetermination.NOT_RECOMMENDED_OTHER;
			}

		} else if (burnPlan.getFireType() == "Headfires") {
			if (weather.getTempature() < 60 || weather.getTempature() > 85) {
				return BurnDetermination.NOT_RECOMMENDED_TEMPERATURE;
			} else if (weather.getTempature() >= 70 && weather.getTempature() <= 80)
				;
			else {
				acceptableCount++;
			}

			if (weather.getWindSpeed() < 5 || weather.getWindSpeed() > 20) {
				return BurnDetermination.NOT_RECOMMENDED_WIND;
			} else if (weather.getWindSpeed() >= 8 && weather.getWindSpeed() <= 15)
				;
			else {
				acceptableCount++;
			}

			if (weather.getWindDirection() == "South" || weather.getWindDirection() == "West") {
				acceptableCount++;
			} else if (weather.getWindDirection() == "SouthWest")
				;
			else {
				return BurnDetermination.NOT_RECOMMENDED_WIND;
			}

			if (weather.getHumidity() < 20 || weather.getHumidity() > 45) {
				return BurnDetermination.NOT_RECOMMENDED_OTHER;
			} else if (weather.getHumidity() >= 25 && weather.getHumidity() <= 40)
				;
			else {
				acceptableCount++;
			}

			if (burnPlan.getBurnTime().isBefore(morningTime) || burnPlan.getBurnTime().isAfter(midDayTime)) {
				return BurnDetermination.NOT_RECOMMENDED_OTHER;
			}
		} else {
			return BurnDetermination.INDETERMINATE;
		}

		if (favoredWeather == false) {
			return BurnDetermination.NOT_RECOMMENDED_OTHER;
		}

		if (acceptableCount > 0) {
			return BurnDetermination.ACCEPTABLE;
		} else {
			return BurnDetermination.DESIRED;
		}
	}

	public static void requieredToolCheck(BurnPlan burnPlan) {
		for (int i = 0; i < requiredTools.size(); i++) {
			for (int j = 0; j < burnPlan.getTools().size(); j++) {
				Tools tool = burnPlan.getTools().get(j);
				if (requiredTools.get(i).getName() == tool.getName()) {
					if (tool.getCapacity() == 0) {
						toolsCheck++;
						continue;
					}
					int quanitiy = 0;
					for (int k = burnPlan.getAcersBurning(); k > 0; k -= requiredTools.get(i).getCapacity()) {
						quanitiy++;
					}
					if (tool.getQuanitity() >= quanitiy) {
						toolsCheck++;
					}
				}
			}
		}
	}
}
