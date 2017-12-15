package com.ruijie.adsha;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.web.servlet.ServletComponentScan;
import org.springframework.boot.web.support.SpringBootServletInitializer;

@SpringBootApplication
@ServletComponentScan
public class AdsHaApplication extends SpringBootServletInitializer {

	public static void main(String[] args) {
		SpringApplication.run(AdsHaApplication.class, args);
	}
}
