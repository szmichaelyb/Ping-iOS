package com.rtayal.gocandid;

import android.app.Application;
import android.util.Log;

import com.parse.Parse;
import com.parse.ParseException;
import com.parse.ParseObject;
import com.parse.SaveCallback;

public class GoCandid extends Application {

	public GoCandid() {
		// TODO Auto-generated constructor stub
	}
	
	@Override
	public void onCreate() {
		// TODO Auto-generated method stub
		super.onCreate();
		Parse.initialize(this, "RjjejatHY8BsqER68vg48jtr9nRv0FVAfKqryjja", "hTwjS9Ng9azIQoOfpQ6xeYX3Ah8mesiCWGt0gz3b");
	}

}
