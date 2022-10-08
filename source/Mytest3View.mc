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
    var sunrise = null;
    var sunset = null;
    var bat;
    var bat_view;

    function initialize() {
        WatchFace.initialize();
        DAY_IN_ADVANCE = 0;
        sc = new SunCalc();
        lastLoc = null;
        app = Application.getApp();
        app.setProperty("lastLoc", null);
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
    function onShow() as Void {
    }

    // Update the view
    function onUpdate(dc as Dc) as Void {
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

          lastLoc = Activity.getActivityInfo().currentLocation;
          if (lastLoc != null) {
            // persistent storage; currentLocation is not stored forever
            //app.setProperty("lastLoc", lastLoc); // doesnt work?? variable type?
            app.setProperty("lastLoc", lastLoc.toRadians()); // doesnt work?? variable type?
          }
        }
        lastLoc = app.getProperty("lastLoc"); // doesnt work?? variable type?
        if (lastLoc != null) {       
          if ((sunrise == null) or (sunset == null) or (now.hour == 0 and now.min == 0 and now.sec == 0)) {
            sunrise = Time.Gregorian.info(getMoment(SUNRISE), Time.FORMAT_SHORT);
            sunset = Time.Gregorian.info(getMoment(SUNSET), Time.FORMAT_SHORT);
            sunrise_string = Lang.format("$1$:$2$", [sunrise.hour.format("%02d"), sunrise.min.format("%02d")]);
            sunset_string = Lang.format("$1$:$2$", [sunset.hour.format("%02d"), sunset.min.format("%02d")]);
          }
        }
        //var view = View.findDrawableById("TimeLabel") as Text;
        sunrise_view.setText(sunrise_string);
        sunset_view.setText(sunset_string);
        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);
    }


    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.

    function check_battery_status() as Void {
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

    function onHide() as Void {
    }

    // The user has just looked at their watch. Timers and animations may be started here.
    function onExitSleep() as Void {
    }

    // Terminate any active timers and prepare for slow updates.
    function onEnterSleep() as Void {
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
