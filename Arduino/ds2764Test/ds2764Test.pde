/////////////////////////////////////////////////////////////////////
// Example Test application for the Maxim DS2764 IC. 
// A LiPo protection IC
/////////////////////////////////////////////////////////////////////
// J.C. Woltz 2010.11.15
/////////////////////////////////////////////////////////////////////
// This work is licensed under the Creative Commons 
// Attribution-ShareAlike 3.0 Unported License. To view a copy of 
// this license, visit http://creativecommons.org/licenses/by-sa/3.0/
// or send a letter to 
// Creative Commons, 
// 171 Second Street, 
// Suite 300, 
// San Francisco, California, 94105, USA.
/////////////////////////////////////////////////////////////////////

#include <Wire.h> 
#define DS00OV	0x80
#define DS00UV	0x40
#define DS00COC	0x20
#define DS00DOC	0x10
#define DS00CC	0x08
#define DS00DC	0x04
#define DS00CE	0x02
#define DS00DE	0x01

int dsAddress = 0x34;
int reading = 0; 
byte inByte;
int seconds;
int minutes;
int hours;
int t;

void setup() 
{ 
	Serial.begin(9600);          // start serial communication at 9600bps 
	Serial.print(".");
	Wire.begin();                // join i2c bus (address optional for master) 
	//resetdsProtection();
	Serial.println("End Setup");
} 

void loop() 
{ 
	if (Serial.available()) {
		inByte = Serial.read();
		switch (inByte) {
		case '1':
			Wire.beginTransmission(dsAddress);
			Wire.send(0x00);
			Wire.send(0x03);  //Clear OV and UV, enable charge and discharge
			//Wire.send(0x00);  //Clear OV and UV, diable charge and discharge
			Wire.endTransmission();
			Serial.println("Enable charge and discharge");
			break;
		case '0':
			Wire.beginTransmission(dsAddress);
			Wire.send(0x00);
			//Wire.send(0x03);  //Clear OV and UV, enable charge and discharge
			Wire.send(0x00);  //Clear OV and UV, diable charge and discharge
			Wire.endTransmission();
			Serial.println("Disable Charge and Discharge");
			break;
		}
	}


	
	getdsProtection();
	getdsVoltage();  
	getdsTemp();
	Serial.print(",");
t = millis() / 1000;
hours = t / 3600;
minutes = t/60 - (60 * hours);
seconds = t - (3600 * hours) - (60 * minutes);
Serial.print(hours);
Serial.print(":");
Serial.print(minutes);
Serial.print(":");
Serial.print(seconds);
Serial.print(",");
	Serial.print(millis());

	for (int i=0; i<10; i++) {
		Serial.print(".");
		delay(100);
	}
	Serial.println();

} 

float getdsTemp() {
	// Read Voltage Register
	Wire.beginTransmission(dsAddress);
	Wire.send(0x18);
	Wire.endTransmission();

	Wire.requestFrom(dsAddress, 2);
	if(2 <= Wire.available())     // if two bytes were received 
	{ 
		reading = Wire.receive();   // receive high byte (overwrites previous reading) 
		reading = reading << 8;     // shift high byte to be high 8 bits 
		reading += Wire.receive();  // receive low byte as lower 8 bits 
		reading = reading >> 5;
		reading = reading * 0.125;
		Serial.print(reading);    // print the reading 
		Serial.print(" degree C ");
	}

	return reading;
}

int getdsProtection(void) {
	int dsProtect;
	int dsStatus;
	// Read Protection Register
	Wire.beginTransmission(dsAddress);
	Wire.send(0x00);
	Wire.endTransmission();
	Wire.requestFrom(dsAddress, 2);
	if(2 <= Wire.available())     // if two bytes were received 
	{ 
		dsProtect = Wire.receive();
		dsStatus = Wire.receive();
		//Serial.println(dsProtect,BIN);
		//Serial.println(dsStatus,BIN);

		if (dsProtect & DS00OV) { Serial.print("Over Voltage, "); }
		if (dsProtect & DS00UV) { Serial.print("Under Voltage, "); }
		if (dsProtect & DS00COC) { Serial.print("Charge Over Current, "); }
		if (dsProtect & DS00DOC) { Serial.print("Discharge Over Current, "); }
		if (dsProtect & DS00CC) { Serial.print("CC Pin state, "); }
		if (dsProtect & DS00DC) { Serial.print("DC Pin State, "); }
		if (dsProtect & DS00CE) { Serial.print("Charging Enabled, "); }
		if (dsProtect & DS00DE) { Serial.print("Discharging Enabled, "); }
		if (dsStatus & 32) { Serial.print("Sleep mode enabled, ");}
	}
	return dsProtect;
}

float getdsVoltage(void) {
	int voltage;
	int current;
	int acurrent;
	// Read Voltage Register
	Wire.beginTransmission(dsAddress);
	Wire.send(0x0C);
	Wire.endTransmission();

	Wire.requestFrom(dsAddress, 6);
	delay(4);
	if(6 <= Wire.available())     // if six bytes were received 
	{ 
		voltage = Wire.receive();
		voltage = voltage << 8;
		voltage += Wire.receive();
		voltage = voltage >> 5;
		voltage = voltage * 4.88;
		
		current = Wire.receive();
		current = current << 8;
		current += Wire.receive();
		
		acurrent = Wire.receive();
		acurrent = acurrent << 8;
		acurrent += Wire.receive();
		
		current = current >>3;
		double c = (current * 0.625);
		
		acurrent = acurrent * 0.25;
		
		Serial.print("V: ");
		Serial.print(voltage);
		Serial.print(", C: ");
		Serial.print(c);
		Serial.print("mA, Accumulated C: ");
		Serial.print(acurrent);
		Serial.print("mAh, ");
	}
	return voltage;
}

int resetdsProtection(void) {
	int dsProtect;
	int dsStatus;
	// Read Protection Register
	Wire.beginTransmission(dsAddress);
	Wire.send(0x00);
	Wire.send(0x03);  //Clear OV and UV, enable charge and discharge
	//Wire.send(0x00);  //Clear OV and UV, diable charge and discharge
	Wire.endTransmission();
	delay(10);
	// Read Protection Register
	Wire.beginTransmission(dsAddress);
	Wire.send(0x00);
	Wire.endTransmission();

	Wire.requestFrom(dsAddress, 2);
	if(2 <= Wire.available())     // if two bytes were received 
	{ 
		dsProtect = Wire.receive();
		dsStatus = Wire.receive();
		Serial.println(dsProtect,BIN);    // print the reading 
		Serial.println(dsStatus,BIN);

	}
	return dsProtect;
}

int menu(void) {
}
