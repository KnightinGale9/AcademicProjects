import java.sql.*;
import java.util.Scanner;
public class lab4JDBC {

   public static void main(String[] args) {
      Scanner scan = new Scanner(System.in);
      try
      {
         String url="jdbc:mysql://localhost:3306/?user=root";
         Connection con = DriverManager.getConnection(url);
         Statement ST =con.createStatement();
         ResultSet rs;
         String query="";
         int key=0;
         int tripNumber,busID;
         String date,startTime,arrivalTime,driverName,phoneNumber;
         switch (key) {
            case 1://Q1
               query="SELECT Trip.TripNumber,StartLocationName,DestinationName,"+
               "Date,ScheduledStartTime,ScheduleArrivalTime,DriverName,BusID"+
               "FROM Trip,TripOffering WHERE Trip.TripNumber=TripOffering.TripNumber";
               rs=ST.executeQuery(query);
               break;
            case 2:
               int portion=0;
               switch (portion) {
                  case 1:
                     //Q2A
                     tripNumber=scan.nextInt();
                     date=scan.nextLine();
                     scan.nextInt();
                     startTime=scan.nextLine();
                     query = String.format("delete from `TripOffering` WHERE TripNumber=%d and Date='%s' and ScheduledStartTime='%s'"
                                           ,tripNumber,date,startTime);
                     ST.executeUpdate(query);
                     break;
                  case 2:
                  //Q2B
                     while(true)
                     {
                        tripNumber=scan.nextInt();
                        date=scan.nextLine();
                        scan.nextInt();
                        startTime=scan.nextLine();
                        scan.nextLine();
                        arrivalTime=scan.nextLine();
                        scan.nextLine();
                        driverName=scan.nextLine();
                        busID=scan.nextInt();
                        query = String.format("INSERT INTO `TripOffering` VALUES (%d,'%s','%s','%s','%s',%d);"
                                             , tripNumber,date,startTime,arrivalTime,driverName,busID);
                        ST.executeUpdate(query);
                        System.out.println("do you want to add another?(Y/N)");
                        String check= scan.nextLine();
                        if(check=="N")
                              break;
                     }
                     break;
                  case 3:
                     //Q2C
                     driverName=scan.nextLine();
                     tripNumber=scan.nextInt();
                     date=scan.nextLine();
                     scan.nextInt();
                     startTime=scan.nextLine();
                     query = String.format("UPDATE tripOffering SET DriverName = '%s' WHERE TripNumber = %d AND" + 
                                          "Date = '%s' AND ScheduledStartTime = '%s'", driverName,tripNumber,date,startTime);
                     ST.executeUpdate(query);
                     break;
                  case 4:
                   //Q2D
                     busID=scan.nextInt();
                     tripNumber=scan.nextInt();
                     date=scan.nextLine();
                     scan.nextInt();
                     startTime=scan.nextLine();
                     query = String.format("UPDATE tripOffering SET BusID = '%d' WHERE TripNumber = %d AND" + 
                                          "Date = '%s' AND ScheduledStartTime = '%s'", busID,tripNumber,date,startTime);
                     ST.executeUpdate(query);
                     break;
               }
               break;
            case 3:
               query="";
               rs=ST.executeQuery(query);
               System.out.println(rs);
               break;
            case 4:
               driverName=scan.nextLine();
               date=scan.nextLine();
               query=String.format("Select TT.DriverName, TT.date, TT.ScheduledStartTime, T.StartLocationName, T.DestinationName"+
               "FROM Trip T, TripOffering TT WHERE T.TripNumber=TT.TripNumber and TT.DriverName='%s'" +
               "and date<= adddate('%s',INTERVAL 7 DAY) AND "+
               "TT.date in(SELECT TTT.date FROM TripOffering TTT WHERE date>= '%s'"
               , driverName,date,date);
               rs=ST.executeQuery(query);
               break;
            case 5:
               //Q5 Add a Drive 
               driverName =scan.nextLine();
               scan.nextLine();
               phoneNumber=scan.nextLine();
               query=String.format("INSERT INTO `Driver` VALUES ('%s','%s');",driverName,phoneNumber);
               ST.executeUpdate(query);
               break;
            case 6:
               //Q6 Add a Bus
               busID=scan.nextInt();
               String model=scan.nextLine();
               int year=scan.nextInt();
               query =String.format("Insert into BUS (busID, Model, Year) values (ID, busModel, 2022)", busID,model,year);
               ST.executeUpdate(query);
               break;
            case 7:
               //Q7 Delete a Bus
               busID=scan.nextInt();
               query=String.format("Delete from Bus Where BusID = ID", busID);
               ST.executeUpdate(query);
               break;
            case 8:
               tripNumber=scan.nextInt();
               date=scan.nextLine();
               scan.nextLine();
               startTime=scan.nextLine();
               int stopNumber=scan.nextInt();
               scan.nextLine();
               arrivalTime=scan.nextLine();
               scan.nextLine();
               String actualStart=scan.nextLine();
               scan.nextLine();
               String actualArrive=scan.nextLine();
               int in=scan.nextInt();
               int out=scan.nextInt();
               query =String.format("Insert into ActualTripStopInfo(TripNumber, date, ScheduledStartTime, "
               +"StopNumber, ScheduledArrivalTime, ActualStartTime, ActualArrivalTime, NumberOfPassengerIn,NumberOf PassengerOut)"+
               "Values(%d,'%s','%s',%d,'%s','%s','%s',%d,%d)", tripNumber,date,startTime,stopNumber,arrivalTime,
               actualStart,actualArrive,in,out);
               break;
         }
      }
      catch(Exception e)
      {
         System.out.println(e);
      }
      scan.close();
   }
}
