package edu.unl.cse.soft160.loops;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.time.LocalDate;

public class TemperatureAnalysis {
	public static LocalDate getDateForLowestTemperature(List<Observation> observations) {
		
		if (observations.size() == 0) {
			return null;
		}
		
		Double coldestTemp = observations.get(0).getMeasurement();
		LocalDate coldestDate = observations.get(0).getDate();
		
		for (int i = 1; i < observations.size(); i++) {
			Observation observe = observations.get(i);
			Double temp = observe.getMeasurement();
			LocalDate date = observe.getDate();
			if (coldestTemp > temp) {
				coldestTemp = temp;
				coldestDate = date;
			}
		}
		return coldestDate;
	}

	public static Double getLowestTemperatureBetweenTwoDates(List<Observation> observations, LocalDate date1, LocalDate date2) {
		if (observations.size() == 0) {
			return null;
		}
		
		Double[] Temps = new Double[2];
		
		int j = 0;
		
		
		for (int i = 0; i < observations.size(); i++) {
			Observation observe = observations.get(i);
			LocalDate date = observe.getDate();
			Double temp = observe.getMeasurement();

			if (date.equals(date1) || date.equals(date2)) {
				Temps[j] = temp;
				j++;
			}
			
		}
		
		
		if (Temps[0] > Temps[1]) {
			return Temps[1];
		} else if (Temps[0] < Temps[1]) {
			return Temps[0];
		}
		
		
		
		return null;
	}

	public static List<Double> getExtremeTemperatures(List<Observation> observations) {
		
		List<Double> tempatures = new ArrayList<Double>();
		
		int index = 0;
		
		for (int i = 1; i < observations.size(); i++) {
			Observation observe = observations.get(i);
			LocalDate date = observe.getDate();
			
			LocalDate earlierDate = observations.get(index).getDate();
			
			if (date.isBefore(earlierDate)) {
				index = i;
			}
		}
		
		Double extremeTempature = observations.get(index).getMeasurement();
		
		for (int i = 0; i < observations.size(); i++) {
			if (i == index) continue;
			Observation observe = observations.get(i);
			Double temp = observe.getMeasurement();
			
			if (temp < extremeTempature/2) {
				tempatures.add(temp);
			}
		}
		
		Collections.sort(tempatures);
		
		return tempatures;
	}

	public static Double getMostRecentExtremeTemperature(List<Observation> observations) {
		
		List<Double> tempatures = new ArrayList<Double>();
		
		int index = 0;
		
		for (int i = 1; i < observations.size(); i++) {
			Observation observe = observations.get(i);
			LocalDate date = observe.getDate();
			
			LocalDate earlierDate = observations.get(index).getDate();
			
			if (earlierDate.isBefore(date)) {
				index = i;
			}
		}
		
		Double extremeTempature = observations.get(index).getMeasurement();
		
		for (int i = 0; i < observations.size(); i++) {
			if (i == index) continue;
			Observation observe = observations.get(i);
			Double temp = observe.getMeasurement();
			
			if (temp < extremeTempature/2) {
				tempatures.add(temp);
			}
		}
		
		Collections.sort(tempatures);
		
		if (tempatures.size() != 0) {
			double Temp = tempatures.get(tempatures.size()-1);
			return Temp;
		} else {
			return null;
		}
	}
}
