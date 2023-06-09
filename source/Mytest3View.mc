import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;
import Toybox.Activity;
import Toybox.Application;
import Toybox.Time;

class Mytest3View extends WatchUi.WatchFace {

    var sc;
    var DAY_IN_ADVANCE;
    var now;
    var lastLoc;
    var app;
    var time_view;
    var sunrise_view;
    var sunset_view;
    var day_view;
    var date_view;
    var time_string;
    var date_string;
    var day_string;
    var sunrise_string = "-";
    var sunset_string = "-";
    var sunrise;
    var sunset;
    var bat;
    var bat_view;


    function initialize() {
        WatchFace.initialize();
        DAY_IN_ADVANCE = 0;
        sc = new SunCalc();
        app = Application.getApp();
        if (app.getProperty("sunrise_string") == null) {
          app.setProperty("sunrise_string", "-");
          app.setProperty("sunset_string", "-");
        }
    }

    // Load your resources here
    function onLayout(dc as Dc) as Void {
        
        setLayout(Rez.Layouts.WatchFace(dc));

        day_view = View.findDrawableById("DayLabel") as Text;
        date_view = View.findDrawableById("DateLabel") as Text;
        time_view = View.findDrawableById("TimeLabel") as Text;
        sunrise_view = View.findDrawableById("SunriseLabel") as Text;
        sunset_view = View.findDrawableById("SunsetLabel") as Text;
        bat_view = View.findDrawableById("BatIcon") as Bitmap;

    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() {
      check_battery_status();
    }


    // Update the view
    function onUpdate(dc) {
        // Called every minute
        now = Gregorian.info(Time.now(), Time.FORMAT_MEDIUM);

        time_string = Lang.format("$1$:$2$:$3$", [now.hour, now.min.format("%02d"), now.sec.format("%02d")]);
		    date_string = Lang.format("$1$ $2$. $3$", [now.month, now.day, now.year]);
		    day_string = Lang.format("$1$", [now.day_of_week]);

        time_view.setText(time_string);
        date_view.setText(date_string);
        day_view.setText(day_string);       

        // every minute ...
        if (now.sec == 0) {
          check_battery_status();
          check_and_store_position();
        }
        lastLoc = app.getProperty("lastLoc"); // doesnt work?? variable type?
        if (lastLoc != null) {     
          sunrise_string = app.getProperty("sunrise_string");
          sunset_string = app.getProperty("sunset_string");  
          if ((sunrise_string.equals("-")) or (sunset_string.equals("-")) or (now.hour == 0 and now.min == 0 and now.sec == 0)) {
            sunrise = Time.Gregorian.info(getMoment(SUNRISE), Time.FORMAT_SHORT);
            sunset = Time.Gregorian.info(getMoment(SUNSET), Time.FORMAT_SHORT);
            sunrise_string = Lang.format("$1$:$2$", [sunrise.hour.format("%02d"), sunrise.min.format("%02d")]);
            sunset_string = Lang.format("$1$:$2$", [sunset.hour.format("%02d"), sunset.min.format("%02d")]);
            app.setProperty("sunrise_string", sunrise_string);
            app.setProperty("sunset_string", sunset_string);
          }
        }
        sunrise_string = app.getProperty("sunrise_string");
        sunset_string = app.getProperty("sunset_string");
        sunrise_view.setText(sunrise_string);
        sunset_view.setText(sunset_string);
        //var view = View.findDrawableById("TimeLabel") as Text;
        // Call the parent onUpdate function to redraw the layout
        //View.onPartialUpdate(dc);

        View.onUpdate(dc);
    }

    function check_and_store_position() {
      lastLoc = Activity.getActivityInfo().currentLocation;
      if (lastLoc != null) {
        // persistent storage; currentLocation is not stored forever
        //app.setProperty("lastLoc", lastLoc); // doesnt work?? variable type?
        app.setProperty("lastLoc", lastLoc.toRadians()); // doesnt work?? variable type?
      }
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.

    function check_battery_status() {
      bat = System.getSystemStats().battery;
      if (bat < 5.0) {           
        bat_view.setBitmap(Rez.Drawables.bat5);
      } else if (bat < 25.0) {
        bat_view.setBitmap(Rez.Drawables.bat25);           
      } else if (bat < 50.0) {
        bat_view.setBitmap(Rez.Drawables.bat50);
      } else if (bat < 75.0) {
        bat_view.setBitmap(Rez.Drawables.bat75);  
      } else {
        bat_view.setBitmap(Rez.Drawables.bat100);  
      } 
    }

    function onHide() {
    }

    // The user has just looked at their watch. Timers and animations may be started here.
    function onExitSleep() {
    }

    // Terminate any active timers and prepare for slow updates.
    function onEnterSleep() {
    }

    function getMoment(what) {
        var day = DAY_IN_ADVANCE;
        if (what > ASTRO_DUSK) {
            day++;
            what = ASTRO_DAWN;
        }
        // for testing now = new Time.Moment(1483225200);
        return sc.calculate(new Time.Moment(Time.now().value() + day * Time.Gregorian.SECONDS_PER_DAY), lastLoc, what);
    }

}
