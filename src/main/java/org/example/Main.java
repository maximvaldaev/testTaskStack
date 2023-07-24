package org.example;

import java.io.*;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.Scanner;

public class Main {
    final static private String INPUT_FILE = "чеки.txt";
    final static private String OUT_FILE = "чеки_по_папкам.txt";
    final static private String [] MONTHS = {"январь", "февраль", "март",
            "апрель", "май","июнь", "июль","август", "сентябрь",
            "октябрь", "ноябрь","декабрь"};

    public static void main(String[] args) {
        ArrayList<String> checks = new ArrayList<String>();
        ArrayList<String> newChecks = new ArrayList<String>();
        HashSet<String> hashSet = new HashSet<String>();
        Scanner myReader = null;
        try {
            File myObj = new File(INPUT_FILE);
            myReader = new Scanner(myObj);

            while (myReader.hasNextLine()) {
                String data = myReader.nextLine();
                checks.add(data);
                hashSet.add(data.substring(0, data.indexOf("_")));
            }

        } catch (FileNotFoundException e) {
            e.printStackTrace();
        } finally {
            myReader.close();
        }

        ArrayList<String> notPaid = new ArrayList<String>();
        notPaid.add("не оплачены:");
        for (int i = 0; i < MONTHS.length; i++) {
            ArrayList<String> tempNotPaid = new ArrayList<>(hashSet);
            for (String value : checks) {
                String s = value.substring(value.indexOf("_") + 1, value.indexOf("."));
                if (s.equals(MONTHS[i])) {
                    newChecks.add("/" + MONTHS[i] + "/" + value.substring(0, value.indexOf("_")) + value.substring(value.indexOf(".")));
                    tempNotPaid.remove(value.substring(0, value.indexOf("_")));

                }

            }
            if (!tempNotPaid.isEmpty()) {
                notPaid.add(MONTHS[i] + ":");
                for (String deleted : tempNotPaid) {
                    notPaid.add(deleted);
                }
            }
        }

        File file = new File(OUT_FILE);

        try (PrintWriter out = new PrintWriter(file, StandardCharsets.UTF_8))
        {
            for (String value : newChecks) {
                out.println(value);
            }

            for (String value : notPaid) {
                out.println(value);
            }

        } catch (IOException e) {
            e.printStackTrace();
        }
    }

}