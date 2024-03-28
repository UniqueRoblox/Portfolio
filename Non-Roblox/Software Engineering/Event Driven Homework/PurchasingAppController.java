package edu.unl.cse.soft161.event_driven;

import java.io.IOException;

import javafx.event.ActionEvent;
import javafx.fxml.FXML;
import javafx.scene.Parent;
import javafx.scene.control.Label;
import javafx.scene.control.TextField;

public class PurchasingAppController {
	private int[] amounts = new int[4];

	@FXML
	private Parent mainPage;
	
	@FXML
	private Parent amountPage;

	@FXML
	private Label cart;

	@FXML
	private TextField amountField;

	@FXML
	private Label errorMessage;
	
	private int num;
	
	public void resetGui() {
	    num = -1;
    	errorMessage.setText("");
    	amountField.setText("");
		amountPage.toBack();
	}
	
	public boolean addToCount() {
		int totalCheckout = 0;
		for (int i = 0; i < amounts.length; i++) {
			totalCheckout += amounts[i];
		}
		if (totalCheckout < 0) {
			return false;
		}
		cart.setText("You have " + totalCheckout + " item(s) in your cart.");
		
		return true;
	}

	public void initialize() {
		mainPage.toFront();
		cart.setText("You have 0 item(s) in your cart.");
	}

	@FXML
	private void onFirstProduct(ActionEvent event) {
		num = 0;
		amountField.setPromptText(Integer.toString(amounts[0]));
		amountPage.toFront();
	}

	@FXML
	private void onSecondProduct(ActionEvent event) {
		num = 1;
		amountField.setPromptText(Integer.toString(amounts[1]));
		amountPage.toFront();
	}

	@FXML
	private void onThirdProduct(ActionEvent event) {
		num = 2;
		amountField.setPromptText(Integer.toString(amounts[2]));
		amountPage.toFront();
	}

	@FXML
	private void onFourthProduct(ActionEvent event) {
		num = 3;
		amountField.setPromptText(Integer.toString(amounts[3]));
		
		amountPage.toFront();
	}

	@FXML
	private void onCancel(ActionEvent event) {
		addToCount();
		resetGui();
	}

	@FXML
	private void onOK(ActionEvent event) {
		String amount = amountField.getText();
	    try
	    {
	        Integer.parseInt(amount);
	    } catch (NumberFormatException ex)
	    {
	    	errorMessage.setText("Invalid Input!");
	    	return;
	    }
	    
	    int prevAmount = amounts[num];
	    amounts[num] = Integer.parseInt(amount);
	    
	    if (addToCount() == false) {
	    	amounts[num] = prevAmount;
	    	errorMessage.setText("Total value cannot be less than zero");
	    	return;
	    }
	    
	    resetGui();
	    addToCount();
  
	}
	
	@FXML
	private void onCheckout(ActionEvent event) {
		System.exit(0);
	}
}
