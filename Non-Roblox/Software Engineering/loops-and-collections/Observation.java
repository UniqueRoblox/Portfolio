package edu.unl.cse.soft160.loops;

import java.time.LocalDate;

public class Observation {
	private Double measurement;
	private LocalDate date;

	public Observation(Double measurement, LocalDate date) {
		this.measurement = measurement;
		this.date = date;
	}

	public Double getMeasurement() {
		return measurement;
	}

	public LocalDate getDate() {
		return date;
	}
}
