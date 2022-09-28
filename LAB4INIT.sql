DROP DATABASE IF EXISTS `Lab4`;
CREATE DATABASE `Lab4`; 
USE `Lab4`;

CREATE TABLE `Trip`
(
	`TripNumber` INT PRIMARY KEY,
    `StartLocationName` VARCHAR(50),
    `DestinationName` VARCHAR(50)
);

INSERT INTO `Trip` VALUES (1,'Fontana','Los Angles');
INSERT INTO `TRIP` VALUES (2,'Pasadena','Fontana');
INSERT INTO `TRIP` VALUES (3,'Los Angles','Pasadena');
INSERT INTO `TRIP` VALUES (4,'Los Angles','Fontana');
INSERT INTO `TRIP` VALUES (5,'Fontana','Pasadena');
INSERT INTO `TRIP` VALUES (6,'Pasadena','Los Angles');

CREATE TABLE `Bus`
(
	`BusID` INT PRIMARY KEY,
    `Model` VARCHAR(50),
    `Year` INT
);

INSERT INTO `Bus` VALUES (1,'SOLO',2005);
INSERT INTO `Bus` VALUES (2,'FREE',2010);
INSERT INTO `Bus` VALUES (3,'MONT',2007);
INSERT INTO `Bus` VALUES (4,'FREE',2008);

CREATE TABLE `Driver`
(
	`DriverName` VARCHAR(50) PRIMARY KEY,
    `DriverTelephoneNumber` VARCHAR(13)
);

INSERT INTO `Driver` VALUES ('Tim','(909)312-1232');
INSERT INTO `Driver` VALUES ('Bob','(909)142-6432');
INSERT INTO `Driver` VALUES ('Steve','(909)532-1891');
INSERT INTO `Driver` VALUES ('Logan','(909)888-1239');

CREATE TABLE `TripOffering`
(
	`TripNumber` INT,
    `Date` DATE,
    `ScheduledStartTime` TIME,
    `ScheduleArrivalTime` TIME,
    `DriverName` VARCHAR(50),
    `BusID` INT,
    PRIMARY KEY(`TripNumber`,`Date`,`ScheduledStartTime`),
    Foreign KEY (`TripNumber`) references `Trip`(`TripNumber`)
    ON DELETE CASCADE ON UPDATE CASCADE,
    Foreign KEY (`DriverName`) references `Driver`(`DriverName`)
    ON DELETE CASCADE ON UPDATE CASCADE,
    Foreign KEY (`BusID`) references `Bus`(`BusID`)
    ON DELETE CASCADE ON UPDATE CASCADE
);
INSERT INTO `TripOffering` VALUES (4,'2010-11-9','12:00:00','13:00:00','Tim',1);
INSERT INTO `TripOffering` VALUES (1,'2010-11-11','12:00:00','13:00:00','Tim',1);
INSERT INTO `TripOffering` VALUES (2,'2010-11-11','1:00:00','3:00:00','Tim',1);
INSERT INTO `TripOffering` VALUES (2,'2010-11-11','13:00:00','14:00:00','Bob',3);
INSERT INTO `TripOffering` VALUES (2,'2010-11-13','12:00:00','13:00:00','Tim',1);
INSERT INTO `TripOffering` VALUES (3,'2010-11-15','12:00:00','13:00:00','Tim',1);
INSERT INTO `TripOffering` VALUES (4,'2010-11-19','12:00:00','13:00:00','Tim',1);


CREATE TABLE `Stop`
(
	`StopNumber` INT PRIMARY KEY,
    `StopAddress` VARCHAR(100)
);

INSERT INTO `Stop` VALUES(1,'Los Angles');
INSERT INTO `Stop` VALUES(2,'Fontana');
INSERT INTO `Stop` VALUES(3,'Pasadena');


CREATE TABLE `ActualTripStopInfo`
(
	`TripNumber` INT,
    `Date` DATE,
    `ScheduledStartTime` TIME,
    `StopNumber` INT,
    `ScheduleArrivalTime` TIME,
    `ActualStartTime` TIME,
    `ActualArrivalTime` TIME,
    `NumberOfPassengerIn` INT,
    `NumberOfPassengerOut` INT,
    PRIMARY KEY(`TripNumber`,`Date`,`ScheduledStartTime`,`StopNumber`),
    Foreign KEY (`TripNumber`,`Date`,`ScheduledStartTime`) references `TripOffering`(`TripNumber`,`Date`,`ScheduledStartTime`)
    ON DELETE CASCADE ON UPDATE CASCADE,
    Foreign KEY (`StopNumber`) references `Stop`(`StopNumber`)
    ON DELETE CASCADE ON UPDATE CASCADE
);

INSERT INTO `ActualTripStopInfo` VALUES (1,'2010-11-11','12:00:00',1,'13:00:00','12:10:00','13:10:00',10,9);

CREATE TABLE `TripStopInfo`
(
	`TripNumber` INT,
    `StopNumber` INT,
    `SequenceNumber` INT,
    `DrivingTime` TIME,
    PRIMARY KEY(`TripNumber`,`StopNumber`),
    Foreign KEY (`TripNumber`) references `Trip`(`TripNumber`)
    ON DELETE CASCADE ON UPDATE CASCADE,
    Foreign KEY (`StopNumber`) references `Stop`(`StopNumber`)
    ON DELETE CASCADE ON UPDATE CASCADE
);

INSERT INTO `TripStopInfo` VALUES(1,1,23,'1:00:00');