-- Keep a log of any SQL queries you execute as you solve the mystery.

-- Check the crime scene reports for relevant date and street
SELECT description
FROM crime_scene_reports
WHERE year = 2021 AND month = 7 AND day = 28 AND street = 'Humphrey Street';
-- : Theft of the CS50 duck took place at 10:15am at the Humphrey Street bakery.
--   Interviews were conducted today with three witnesses who were present at the time – each of their interview transcripts mentions the bakery.

-- Check bakery interviews
SELECT name, transcript
FROM interviews
WHERE year = 2021 AND month = 7 AND day = 28 AND transcript LIKE '%bakery%';
-- +---------+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
-- |  name   |                                                                                                                                                     transcript                                                                                                                                                      |
-- +---------+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
-- | Ruth    | Sometime within ten minutes of the theft, I saw the thief get into a car in the bakery parking lot and drive away. If you have security footage from the bakery parking lot, you might want to look for cars that left the parking lot in that time frame.                                                          |
-- | Eugene  | I don't know the thief's name, but it was someone I recognized. Earlier this morning, before I arrived at Emma's bakery, I was walking by the ATM on Leggett Street and saw the thief there withdrawing some money.                                                                                                 |
-- | Raymond | As the thief was leaving the bakery, they called someone who talked to them for less than a minute. In the call, I heard the thief say that they were planning to take the earliest flight out of Fiftyville tomorrow. The thief then asked the person on the other end of the phone to purchase the flight ticket. |
-- | Emma    | I'm the bakery owner, and someone came in, suspiciously whispering into a phone for about half an hour. They never bought anything.                                                                                                                                                                                 |
-- +---------+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+


-- Check ATM at the Leggett Street operations and intersect with those who left bakery parking 10:15am - 10:25am + intersect with short callers
SELECT name, phone_number, passport_number, license_plate
FROM people
WHERE phone_number IN
(
    SELECT phone_number
    FROM people
    WHERE license_plate IN
    (
        SELECT license_plate
        FROM people
        WHERE id IN
        (
            SELECT person_id
            FROM bank_accounts
            WHERE account_number IN
            (
                SELECT account_number
                FROM atm_transactions
                WHERE year = 2021 AND month = 7 AND day = 28 AND atm_location LIKE '%Leggett%' AND transaction_type = 'withdraw'
            )
        )

        INTERSECT

        SELECT license_plate
        FROM bakery_security_logs
        WHERE year = 2021 AND month = 7 AND day = 28 AND hour = 10 AND minute >= 15 AND minute <= 25 AND activity = 'exit'
    )

    INTERSECT

    SELECT caller
    FROM phone_calls
    WHERE year = 2021 AND month = 7 AND day = 28 and duration < 60

);

    -- +-------+----------------+-----------------+---------------+
    -- | name  |  phone_number  | passport_number | license_plate |
    -- +-------+----------------+-----------------+---------------+
    -- | Diana | (770) 555-1861 | 3592750733      | 322W7JE       |
    -- | Bruce | (367) 555-5533 | 5773159633      | 94KL13X       |
    -- +-------+----------------+-----------------+---------------+


-- Check a call about half an hour
SELECT *
FROM phone_calls
WHERE year = 2021 AND month = 7 AND day = 28 AND duration > 1200 AND duration < 2400;
-- NO RESULT!!!

-- Check for suspects to fly tomorrow morning

SELECT name AS 'Thief NAME'
FROM people
WHERE passport_number IN
(
    SELECT passport_number
    FROM people
    WHERE phone_number IN
    (
        SELECT phone_number
        FROM people
        WHERE license_plate IN
        (
            SELECT license_plate
            FROM people
            WHERE id IN
            (
                SELECT person_id
                FROM bank_accounts
                WHERE account_number IN
                (
                    SELECT account_number
                    FROM atm_transactions
                    WHERE year = 2021 AND month = 7 AND day = 28 AND atm_location LIKE '%Leggett%' AND transaction_type = 'withdraw'
                )
            )

            INTERSECT

            SELECT license_plate
            FROM bakery_security_logs
            WHERE year = 2021 AND month = 7 AND day = 28 AND hour = 10 AND minute >= 15 AND minute <= 25 AND activity = 'exit'
        )

        INTERSECT

        SELECT caller
        FROM phone_calls
        WHERE year = 2021 AND month = 7 AND day = 28 and duration < 60

    )

    INTERSECT

    SELECT passport_number
    FROM passengers
    WHERE flight_id IN
    (
        SELECT id
        FROM flights
        WHERE year = 2021 AND month = 7 AND day = 29 AND hour < 12
    )
);

-- +------------+
-- | Thief NAME |
-- +------------+
-- | Bruce      |
-- +------------+


-- Let's check the Bruce's flight destanation
SELECT city AS 'ESCAPE CITY'
FROM airports
WHERE id IN
(
    SELECT destination_airport_id
    FROM flights
    WHERE id IN
    (
        SELECT flight_id
        FROM passengers
        WHERE passport_number IN
        (
            SELECT passport_number
            FROM people
            WHERE phone_number IN
            (
                SELECT phone_number
                FROM people
                WHERE license_plate IN
                (
                    SELECT license_plate
                    FROM people
                    WHERE id IN
                    (
                        SELECT person_id
                        FROM bank_accounts
                        WHERE account_number IN
                        (
                            SELECT account_number
                            FROM atm_transactions
                            WHERE year = 2021 AND month = 7 AND day = 28 AND atm_location LIKE '%Leggett%' AND transaction_type = 'withdraw'
                        )
                    )

                    INTERSECT

                    SELECT license_plate
                    FROM bakery_security_logs
                    WHERE year = 2021 AND month = 7 AND day = 28 AND hour = 10 AND minute >= 15 AND minute <= 25 AND activity = 'exit'
                )

                INTERSECT

                SELECT caller
                FROM phone_calls
                WHERE year = 2021 AND month = 7 AND day = 28 and duration < 60

            )

            INTERSECT

            SELECT passport_number
            FROM passengers
            WHERE flight_id IN
            (
                SELECT id
                FROM flights
                WHERE year = 2021 AND month = 7 AND day = 29 AND hour < 12
            )
        )
    )
);

-- +---------------+
-- |  ESCAPE CITY  |
-- +---------------+
-- | New York City |
-- +---------------+


-- Lets check whome did Bruce call to
SELECT name AS 'ACCOMPLICE name'
FROM people
WHERE phone_number IN
(
    SELECT receiver
    FROM phone_calls
    WHERE year = 2021 AND month = 7 AND day = 28 AND duration < 60 AND caller IN
    (
        SELECT phone_number
        FROM people
        WHERE passport_number IN
        (
            SELECT passport_number
            FROM passengers
            WHERE passport_number IN
            (
                SELECT passport_number
                FROM people
                WHERE phone_number IN
                (
                    SELECT phone_number
                    FROM people
                    WHERE license_plate IN
                    (
                        SELECT license_plate
                        FROM people
                        WHERE id IN
                        (
                            SELECT person_id
                            FROM bank_accounts
                            WHERE account_number IN
                            (
                                SELECT account_number
                                FROM atm_transactions
                                WHERE year = 2021 AND month = 7 AND day = 28 AND atm_location LIKE '%Leggett%' AND transaction_type = 'withdraw'
                            )
                        )

                        INTERSECT

                        SELECT license_plate
                        FROM bakery_security_logs
                        WHERE year = 2021 AND month = 7 AND day = 28 AND hour = 10 AND minute >= 15 AND minute <= 25 AND activity = 'exit'
                    )

                    INTERSECT

                    SELECT caller
                    FROM phone_calls
                    WHERE year = 2021 AND month = 7 AND day = 28 AND duration < 60

                )

                INTERSECT

                SELECT passport_number
                FROM passengers
                WHERE flight_id IN
                (
                    SELECT id
                    FROM flights
                    WHERE year = 2021 AND month = 7 AND day = 29 AND hour < 12
                )
            )
        )
    )
);

-- +-----------------+
-- | ACCOMPLICE name |
-- +-----------------+
-- | Robin           |
-- +-----------------+