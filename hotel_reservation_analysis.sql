
                                        # Hotel Reservation Operations Analytics
										   # MySQL Business Analytics Project

-- Step 1: Create the database
CREATE DATABASE staypoint_hospitality;

-- Step 2: Select the database
USE staypoint_hospitality;

-- Step 3: Create hotels table (no foreign keys)
CREATE TABLE hotels (
    hotel_id VARCHAR(20) PRIMARY KEY,
    hotel_name VARCHAR(100) NOT NULL,
    city VARCHAR(50),
    star_rating INT,
    total_rooms INT,
    opened_date date
);
select * from hotels;


-- Step 4: Create guests table (no foreign keys)
CREATE TABLE guests (
    guest_id VARCHAR(20) PRIMARY KEY,
    guest_name VARCHAR(100) NOT NULL,
    city VARCHAR(50),
    guest_type VARCHAR(20),
    preferred_room_type VARCHAR(20),
    loyalty_tier VARCHAR(20),
    account_since varchar(20)
);
select * from guests;


-- Step 5: Create bookings table (references guests and hotels)
CREATE TABLE bookings (
    booking_id VARCHAR(20) PRIMARY KEY,
    guest_id VARCHAR(20) NOT NULL,
    hotel_id VARCHAR(20) NOT NULL,
    booking_date varchar(20),
    room_type_requested VARCHAR(20),
    booking_channel VARCHAR(30),
    nights_booked INT,
    total_amount DECIMAL(12,2),
    FOREIGN KEY (guest_id) REFERENCES guests(guest_id),
    FOREIGN KEY (hotel_id) REFERENCES hotels(hotel_id)
);
select * from bookings;

-- Step 6: Create rooms table (references hotels)
CREATE TABLE rooms (
    room_id VARCHAR(20) PRIMARY KEY,
    hotel_id VARCHAR(20) NOT NULL,
    room_type VARCHAR(20),
    floor_number INT,
    max_occupancy INT,
    price_per_night DECIMAL(10,2),
    is_active VARCHAR(3),
    FOREIGN KEY (hotel_id) REFERENCES hotels(hotel_id)
);
select * from rooms;

-- Step 7: Create staff table (no foreign keys)
CREATE TABLE staff (
    staff_id VARCHAR(20) PRIMARY KEY,
    staff_name VARCHAR(100) NOT NULL,
    hire_date varchar(20),
    rating DECIMAL(3,2),
    department VARCHAR(30),
    is_active VARCHAR(3)
);
select * from staff;

drop table if EXISTS stays;
-- Step 8: Create stays table (references bookings, rooms, and staff)
CREATE TABLE stays (
    stay_id VARCHAR(20) PRIMARY KEY,
    booking_id VARCHAR(20) NOT NULL,
    room_id VARCHAR(20),
    staff_id VARCHAR(20),
    check_in_date varchar(20),
    check_out_date varchar(20),
    status VARCHAR(20),
    nights_stayed INT,
    service_requests INT,
    stay_duration_hrs INT,
    FOREIGN KEY (booking_id) REFERENCES bookings(booking_id),
    FOREIGN KEY (room_id) REFERENCES rooms(room_id),
    FOREIGN KEY (staff_id) REFERENCES staff(staff_id)
);
select * from stays;

-- SELECT COUNT(*) FROM stays;

-- CREATE TABLE stays (
--     stay_id INT PRIMARY KEY AUTO_INCREMENT,
--     booking_id INT NOT NULL,
--     room_id INT NOT NULL,
--     staff_id INT,
--     actual_check_in DATETIME,
--     actual_check_out DATETIME,
--     stay_status ENUM('Checked-out', 'No-show', 'Cancelled', 'In-progress') NOT NULL,
--     service_requests INT DEFAULT 0,
--     staff_rating DECIMAL(2,1),
--     notes TEXT,
--     FOREIGN KEY (booking_id) REFERENCES bookings(booking_id),
--     FOREIGN KEY (room_id) REFERENCES rooms(room_id),
--     FOREIGN KEY (staff_id) REFERENCES staff(staff_id)
-- );
-- select * from stays;

														# sprint 3

-- Sprint 3: Basic Analysis / Data Exploration
-- Write SQL queries to answer the following basic questions. The purpose of this sprint is to become familiar with the database before moving into objective-based analysis.
-- 1. What is the total number of guests?
SELECT COUNT(*) AS total_guests FROM guests;

-- 2. What is the total number of bookings?
SELECT COUNT(*) AS total_bookings FROM bookings;

-- 3. What is the total number of stays?
SELECT COUNT(*) AS total_stays FROM stays;
select count(stay_id) as total_stays from stays;

-- 4. What are the different room types available?
SELECT DISTINCT room_type FROM rooms;

-- 5. How many staff members are currently active?
SELECT COUNT(*) AS active_staff FROM staff WHERE is_active = TRUE;

-- 6. What are the different booking channels?
SELECT COUNT(*) AS active_staff FROM staff WHERE is_active = TRUE;

-- 7. What is the total booking amount across all bookings?
SELECT SUM(total_amount) AS total_booking_amount FROM bookings;

-- 8. What is the average nights booked per booking?
SELECT AVG(nights_booked) AS avg_nights_per_booking
FROM bookings;


                                          # Sprint 4: Objective-Based Analysis

-- Analytical Questions:
-- Which hotels generate the most bookings?
SELECT 
    h.hotel_name,
    h.city,
    COUNT(b.booking_id) AS total_bookings,
    SUM(b.total_amount) AS total_revenue,
    AVG(b.total_amount) AS avg_booking_value
FROM hotels h
LEFT JOIN bookings b ON h.hotel_id = b.hotel_id
GROUP BY h.hotel_id, h.hotel_name, h.city
ORDER BY total_bookings DESC;

-- Which booking channels drive the most revenue?
SELECT 
    booking_channel,
    COUNT(*) AS total_bookings,
    SUM(total_amount) AS total_revenue,
    AVG(total_amount) AS avg_revenue,
    AVG(nights_booked) AS avg_nights
FROM bookings
GROUP BY booking_channel
ORDER BY total_bookings DESC;

-- Which room types are most in demand?
SELECT 
    r.room_id,
    COUNT(b.booking_id) AS bookings_count,
    SUM(b.total_amount) AS total_revenue,
    AVG(b.nights_booked) AS avg_nights
FROM rooms r
JOIN bookings b ON r.room_id = r.room_id
GROUP BY r.room_id
ORDER BY bookings_count DESC;

-- How does booking volume trend over time?
SELECT 
    DATE_FORMAT(booking_date, '%Y-%m') AS month,
    COUNT(*) AS bookings_count,
    SUM(total_amount) AS monthly_revenue
FROM bookings
GROUP BY DATE_FORMAT(booking_date, '%Y-%m')
ORDER BY month;

-- Q5: Booking amount distribution by hotel and channel
SELECT 
    h.hotel_name,
    b.booking_channel,
    COUNT(*) AS bookings,
    SUM(b.total_amount) AS revenue
FROM hotels h
JOIN bookings b ON h.hotel_id = b.hotel_id
GROUP BY h.hotel_id, b.booking_channel
ORDER BY h.hotel_name, revenue DESC;

									-- 4.2 Understand Guest Booking Behaviour
-- Analytical Questions:
-- Who are the most frequent bookers?
-- Which guests generate the highest total booking value?
-- How do Individual vs Corporate guests differ in booking patterns?
-- Which hotels do guests prefer?

-- Q1: Guests with multiple bookings (repeat guests)
SELECT 
    g.guest_id,
    -- CONCAT(g.first_name, ' ', g.last_name) AS guest_name,
    b.guest_type,
    COUNT(b.booking_id) AS total_bookings,
    SUM(b.total_amount) AS total_spent,
    AVG(b.total_amount) AS avg_booking_value
FROM guests g
JOIN bookings b ON g.guest_id = b.guest_type
GROUP BY g.guest_id, g.first_name, g.last_name, g.guest_type
HAVING COUNT(b.booking_id) > 1
ORDER BY total_bookings DESC;

-- Q2: Top spending guests
SELECT 
    g.guest_id,
    g.guest_name,
    g.guest_type,
    COUNT(b.booking_id) AS total_bookings,
    SUM(b.total_amount) AS total_spent
FROM guests g
JOIN bookings b ON g.guest_id = b.guest_id
GROUP BY g.guest_id, g.guest_name, g.guest_type
ORDER BY total_spent DESC
LIMIT 20;

-- Q3: Individual vs Corporate guest comparison
SELECT 
    g.guest_type,
    COUNT(DISTINCT g.guest_id) AS unique_guests,
    COUNT(b.booking_id) AS total_bookings,
    SUM(b.total_amount) AS total_revenue,
    AVG(b.total_amount) AS avg_booking_value,
    AVG(b.nights_booked) AS avg_nights
FROM guests g
JOIN bookings b ON g.guest_id = b.guest_id
GROUP BY g.guest_type;

-- Q4: Guest activity across hotels
SELECT 
    h.hotel_name,
    h.city,
    COUNT(DISTINCT b.guest_id) AS unique_guests,
    COUNT(b.booking_id) AS total_bookings
FROM hotels h
JOIN bookings b ON h.hotel_id = b.hotel_id
GROUP BY h.hotel_id, h.hotel_name, h.city
ORDER BY unique_guests DESC;

-- Q5: Guest booking patterns over time by guest type
SELECT 
    DATE_FORMAT(b.booking_date, '%Y-%m') AS month,
    g.guest_type,
    COUNT(*) AS bookings,
    SUM(b.booking_amount) AS revenue
FROM guests g
JOIN bookings b ON g.guest_id = b.guest_id
GROUP BY month, g.guest_type
ORDER BY month, g.guest_type;

                                           # 4.3 Evaluate Stay Performance
    -- Q1: Stay outcomes by hotel
SELECT 
    h.hotel_name,
    s.stay_status,
    COUNT(*) AS stay_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (PARTITION BY h.hotel_id), 2) AS percentage
FROM hotels h
JOIN bookings b ON h.hotel_id = b.hotel_id
JOIN stays s ON b.booking_id = s.booking_id
GROUP BY h.hotel_id, h.hotel_name, s.stay_status
ORDER BY h.hotel_name, stay_count DESC;

-- Q2: Stay duration analysis by status
SELECT 
   status,
    COUNT(*) AS total_stays,
    AVG(DATEDIFF(check_out_date,check_in_date)) AS avg_stay_duration_days,
    MIN(DATEDIFF(check_out_date,check_in_date)) AS min_duration,
    MAX(DATEDIFF(check_out_date, check_in_date)) AS max_duration
FROM stays
WHERE check_out_date IS NOT NULL AND check_in_date IS NOT NULL
GROUP BY status;

-- Q3: Hotel stay success rate (Checked-out vs problems)
SELECT 
    h.hotel_name,
    COUNT(*) AS total_stays,
    SUM(CASE WHEN s.status = 'Checked-out' THEN 1 ELSE 0 END) AS completed_stays,
    SUM(CASE WHEN s.status IN ('No-show', 'Cancelled') THEN 1 ELSE 0 END) AS problem_stays,
    ROUND(SUM(CASE WHEN s.status = 'Checked-out' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS completion_rate
FROM hotels h
JOIN bookings b ON h.hotel_id = b.hotel_id
JOIN stays s ON b.booking_id = s.booking_id
GROUP BY h.hotel_id, h.hotel_name
ORDER BY completion_rate ASC;

-- Q4: Stay performance over time
SELECT 
    DATE_FORMAT(b.booking_date, '%Y-%m') AS month,
    s.stay_status,
    COUNT(*) AS stay_count
FROM bookings b
JOIN stays s ON b.booking_id = s.booking_id
GROUP BY month, s.stay_status
ORDER BY month, stay_count DESC;

-- Q5: Average nights booked vs actual stay duration
SELECT 
    b.nights_booked AS booked_nights,
    AVG(DATEDIFF(s.actual_check_out, s.actual_check_in)) AS actual_avg_nights,
    COUNT(*) AS stay_count
FROM bookings b
JOIN stays s ON b.booking_id = s.booking_id
WHERE s.stay_status = 'Checked-out'
GROUP BY b.nights_booked
ORDER BY b.nights_booked;

                                                    -- optional questions
-- Analytical Questions Formulated
-- 1. What is the distribution of stay outcomes across each hotel?
-- (Identifies which hotels have more completed stays vs. problems.)

SELECT 
    h.hotel_name,
    h.city,
    s.status,
    COUNT(*) AS stay_count
FROM hotels h
JOIN bookings b ON h.hotel_id = b.hotel_id
JOIN stays s ON b.booking_id = s.booking_id
GROUP BY h.hotel_id, h.hotel_name, h.city, s.status
ORDER BY h.hotel_name, stay_count DESC;

-- 2. Which hotels have the highest stay completion rates, and which have the most no-shows/cancellations?
-- (Finds operational hotspots that need attention.)
SELECT 
    h.hotel_name,
    h.city,
    COUNT(*) AS total_stays,
    SUM(CASE WHEN s.status = 'Checked-out' THEN 1 ELSE 0 END) AS completed_stays,
    SUM(CASE WHEN s.status = 'No-show' THEN 1 ELSE 0 END) AS no_shows,
    SUM(CASE WHEN s.status = 'Cancelled' THEN 1 ELSE 0 END) AS cancellations,
    SUM(CASE WHEN s.status = 'In-progress' THEN 1 ELSE 0 END) AS in_progress,
    ROUND(SUM(CASE WHEN s.status = 'Checked-out' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) 
        AS completion_rate_pct,
    ROUND(SUM(CASE WHEN s.status IN ('No-show', 'Cancelled') THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) 
        AS problem_rate_pct
FROM hotels h
JOIN bookings b ON h.hotel_id = b.hotel_id
JOIN stays s ON b.booking_id = s.booking_id
GROUP BY h.hotel_id, h.hotel_name, h.city
ORDER BY problem_rate_pct DESC;

-- 3. How does actual stay duration vary by stay status?
-- (Checks if cancelled/no-show bookings were typically shorter or longer.)

SELECT 
    s.status,
    COUNT(*) AS total_stays,
    AVG(s.nights_stayed) AS avg_nights_stayed,
    AVG(DATEDIFF(s.check_out_date, s.check_in_date)) AS avg_nights_from_dates,
    MIN(s.nights_stayed) AS min_nights,
    MAX(s.nights_stayed) AS max_nights
FROM stays s
WHERE s.check_in_date IS NOT NULL 
  AND s.check_out_date IS NOT NULL
GROUP BY s.status
ORDER BY avg_nights_stayed DESC;
-- 4. How has stay performance trended month-over-month?
-- (Reveals seasonal patterns or declining/improving operations.)

SELECT 
    DATE_FORMAT(b.booking_date, '%Y-%m') AS month,
    s.status,
    COUNT(*) AS stay_count
FROM bookings b
JOIN stays s ON b.booking_id = s.booking_id
GROUP BY DATE_FORMAT(b.booking_date, '%Y-%m'), s.status
ORDER BY month, stay_count DESC;

-- 5. Which hotels generate high booking volume but also suffer poor stay outcomes?
-- (High activity + high failure = priority for management intervention.)
SELECT 
    h.hotel_name,
    COUNT(*) AS total_stays,
    COUNT(DISTINCT b.booking_id) AS total_bookings,
    SUM(b.total_amount) AS total_associated_revenue,
    SUM(CASE WHEN s.status IN ('No-show', 'Cancelled') THEN 1 ELSE 0 END) AS problem_stays,
    ROUND(SUM(CASE WHEN s.status IN ('No-show', 'Cancelled') THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) 
        AS problem_rate_pct,
    ROUND(SUM(CASE WHEN s.status = 'Checked-out' THEN b.total_amount ELSE 0 END), 2) 
        AS realized_revenue
FROM hotels h
JOIN bookings b ON h.hotel_id = b.hotel_id
JOIN stays s ON b.booking_id = s.booking_id
GROUP BY h.hotel_id, h.hotel_name
ORDER BY total_stays DESC, problem_rate_pct DESC;

-- 6. What is the revenue impact of each stay outcome?
-- (Quantifies how much booking value is lost to no-shows and cancellations.)
SELECT 
    s.status,
    COUNT(*) AS stay_count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM stays), 2) AS pct_of_all_stays,
    SUM(b.total_amount) AS associated_booking_value,
    AVG(b.total_amount) AS avg_booking_value
FROM stays s
JOIN bookings b ON s.booking_id = b.booking_id
GROUP BY s.status
ORDER BY stay_count DESC;

-- 7. How long have "In-progress" stays been open, and where are they concentrated?
-- (Flags stale in-progress records that may need follow-up.)      
SELECT 
    s.stay_id,
    b.booking_id,
    h.hotel_name,
    g.guest_name,
    s.check_in_date,
    DATEDIFF(CURDATE(), s.check_in_date) AS days_in_progress,
    b.total_amount
FROM stays s
JOIN bookings b ON s.booking_id = b.booking_id
JOIN hotels h ON b.hotel_id = h.hotel_id
JOIN guests g ON b.guest_id = g.guest_id
WHERE s.status = 'In-progress'
ORDER BY days_in_progress DESC;
                                 

                                               # 4.4 Understand Staff and Room Performance
-- Business Objective: The Operations team wants to understand how its hotel resources are being utilized and how they are performing.
-- Things to Consider While Analyzing:
-- Compare the number of stays handled by staff members.
-- Compare staff performance across stay outcomes.
-- Examine stay duration across staff members.
-- Compare room usage across different room types.
-- Look at stay performance across different rooms.

-- Q1: Stays Handled by Each Staff Member
SELECT 
    s.staff_id,
    s.staff_name,
    s.department,
    s.rating AS rating,
    h.hotel_name,
    COUNT(st.stay_id) AS stays_handled,
    SUM(CASE WHEN st.status = 'Checked-out' THEN 1 ELSE 0 END) AS completed_stays,
    SUM(CASE WHEN st.status IN ('No-show', 'Cancelled') THEN 1 ELSE 0 END) AS problem_stays
FROM staff s
JOIN hotels h ON s.hotel_id = h.hotel_id
LEFT JOIN stays st ON s.staff_id = st.staff_id
GROUP BY s.staff_id, s.staff_name, s.department, s.rating, h.hotel_name
ORDER BY stays_handled DESC;

-- Q2: Staff Performance Across Stay Outcomes

SELECT 
    s.staff_id,
    s.staff_name,
    s.rating,
    st.status,
    COUNT(*) AS stay_count,
    AVG(st.service_requests) AS avg_service_requests,
    AVG(st.nights_stayed) AS avg_nights
FROM staff s
LEFT JOIN stays st ON s.staff_id = st.staff_id
GROUP BY s.staff_id, s.staff_name, s.rating, st.status
ORDER BY s.staff_id, stay_count DESC;

-- Q3: Staff Stay Duration Analysis
SELECT 
    s.staff_id,
    s.staff_name,
    s.department,
    COUNT(st.stay_id) AS total_stays,
    AVG(st.nights_stayed) AS avg_nights_handled,
    AVG(st.stay_duration_hrs) AS avg_duration_hrs,
    SUM(st.service_requests) AS total_service_requests
FROM staff s
LEFT JOIN stays st ON s.staff_id = st.staff_id
GROUP BY s.staff_id, s.staff_name, s.department
ORDER BY avg_nights_handled DESC;

-- Q4: Room Usage by Room Type
SELECT 
    r.room_type,
    COUNT(DISTINCT r.room_id) AS total_rooms,
    COUNT(st.stay_id) AS total_stays,
    ROUND(COUNT(st.stay_id) * 1.0 / COUNT(DISTINCT r.room_id), 2) AS stays_per_room,
    AVG(st.service_requests) AS avg_service_requests,
    AVG(st.nights_stayed) AS avg_nights_stayed
FROM rooms r
LEFT JOIN stays st ON r.room_id = st.room_id
GROUP BY r.room_type
ORDER BY total_stays DESC;

-- Q5: Room Capacity vs. Service Requests
SELECT 
    r.max_occupancy,
    COUNT(st.stay_id) AS total_stays,
    AVG(st.service_requests) AS avg_service_requests,
    SUM(st.service_requests) AS total_service_requests,
    ROUND(AVG(st.service_requests), 2) AS avg_requests_per_stay
FROM rooms r
LEFT JOIN stays st ON r.room_id = st.room_id
GROUP BY r.max_occupancy
ORDER BY r.max_occupancy;

-- Q6: Individual Room Performance

SELECT 
    r.room_id,
    r.room_type,
    r.floor_number,
    r.max_occupancy,
    h.hotel_name,
    COUNT(st.stay_id) AS total_stays,
    SUM(CASE WHEN st.status = 'Checked-out' THEN 1 ELSE 0 END) AS completed,
    SUM(CASE WHEN st.status IN ('No-show', 'Cancelled') THEN 1 ELSE 0 END) AS problems,
    SUM(st.service_requests) AS total_service_requests,
    ROUND(SUM(CASE WHEN st.status = 'Checked-out' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) 
        AS completion_rate_pct
FROM rooms r
JOIN hotels h ON r.hotel_id = h.hotel_id
LEFT JOIN stays st ON r.room_id = st.room_id
GROUP BY r.room_id, r.room_type, r.floor_number, r.max_occupancy, h.hotel_name
ORDER BY problems DESC, total_stays DESC;

                                              -- Important SQL Queries
-- Q1: Stays Handled by Each Staff Member
SELECT 
    s.staff_id,
    s.staff_name,
    s.department,
    s.rating AS staff_rating,
    h.hotel_name,
    COUNT(st.stay_id) AS stays_handled,
    SUM(CASE WHEN st.status = 'Checked-out' THEN 1 ELSE 0 END) AS completed_stays,
    SUM(CASE WHEN st.status IN ('No-show', 'Cancelled') THEN 1 ELSE 0 END) AS problem_stays
FROM staff s
JOIN hotels h ON s.hotel_id = h.hotel_id
LEFT JOIN stays st ON s.staff_id = st.staff_id
GROUP BY s.staff_id, s.staff_name, s.department, s.rating, h.hotel_name
ORDER BY stays_handled DESC;

-- Q2: Staff Performance Across Stay Outcomes
SELECT 
    s.staff_id,
    s.staff_name,
    s.rating,
    st.status,
    COUNT(*) AS stay_count,
    AVG(st.service_requests) AS avg_service_requests,
    AVG(st.nights_stayed) AS avg_nights
FROM staff s
LEFT JOIN stays st ON s.staff_id = st.staff_id
GROUP BY s.staff_id, s.staff_name, s.rating, st.status
ORDER BY s.staff_id, stay_count DESC;

-- Q3: Staff Stay Duration Analysis
SELECT 
    s.staff_id,
    s.staff_name,
    s.department,
    COUNT(st.stay_id) AS total_stays,
    AVG(st.nights_stayed) AS avg_nights_handled,
    AVG(st.stay_duration_hrs) AS avg_duration_hrs,
    SUM(st.service_requests) AS total_service_requests
FROM staff s
LEFT JOIN stays st ON s.staff_id = st.staff_id
GROUP BY s.staff_id, s.staff_name, s.department
ORDER BY avg_nights_handled DESC;

-- Q4: Room Usage by Room Type
SELECT 
    r.room_type,
    COUNT(DISTINCT r.room_id) AS total_rooms,
    COUNT(st.stay_id) AS total_stays,
    ROUND(COUNT(st.stay_id) * 1.0 / COUNT(DISTINCT r.room_id), 2) AS stays_per_room,
    AVG(st.service_requests) AS avg_service_requests,
    AVG(st.nights_stayed) AS avg_nights_stayed
FROM rooms r
LEFT JOIN stays st ON r.room_id = st.room_id
GROUP BY r.room_type
ORDER BY total_stays DESC;

-- Q5: Room Capacity vs. Service Requests
SELECT 
    r.max_occupancy,
    COUNT(st.stay_id) AS total_stays,
    AVG(st.service_requests) AS avg_service_requests,
    SUM(st.service_requests) AS total_service_requests,
    ROUND(AVG(st.service_requests), 2) AS avg_requests_per_stay
FROM rooms r
LEFT JOIN stays st ON r.room_id = st.room_id
GROUP BY r.max_occupancy
ORDER BY r.max_occupancy;


-- Q6: Individual Room Performance
SELECT 
    r.room_id,
    r.room_type,
    r.floor_number,
    r.max_occupancy,
    h.hotel_name,
    COUNT(st.stay_id) AS total_stays,
    SUM(CASE WHEN st.status = 'Checked-out' THEN 1 ELSE 0 END) AS completed,
    SUM(CASE WHEN st.status IN ('No-show', 'Cancelled') THEN 1 ELSE 0 END) AS problems,
    SUM(st.service_requests) AS total_service_requests,
    ROUND(SUM(CASE WHEN st.status = 'Checked-out' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) 
        AS completion_rate_pct
FROM rooms r
JOIN hotels h ON r.hotel_id = h.hotel_id
LEFT JOIN stays st ON r.room_id = st.room_id
GROUP BY r.room_id, r.room_type, r.floor_number, r.max_occupancy, h.hotel_name
ORDER BY problems DESC, total_stays DESC;

-- Q7: Room Performance by Hotel
SELECT 
    h.hotel_name,
    r.room_type,
    COUNT(st.stay_id) AS stays_count,
    AVG(st.nights_stayed) AS avg_nights,
    SUM(st.service_requests) AS total_requests,
    ROUND(SUM(CASE WHEN st.status = 'Checked-out' THEN 1 ELSE 0 END) * 100.0 / NULLIF(COUNT(*), 0), 2) 
        AS completion_rate_pct
FROM hotels h
JOIN rooms r ON h.hotel_id = r.hotel_id
LEFT JOIN stays st ON r.room_id = st.room_id
GROUP BY h.hotel_id, h.hotel_name, r.room_type
ORDER BY h.hotel_name, stays_count DESC;

-- Q8: Revenue Contribution by Room Type
SELECT 
    r.room_type,
    COUNT(st.stay_id) AS total_stays,
    SUM(b.total_amount) AS total_associated_revenue,
    AVG(b.total_amount) AS avg_booking_value,
    SUM(st.service_requests) AS total_service_requests
FROM rooms r
JOIN stays st ON r.room_id = st.room_id
JOIN bookings b ON st.booking_id = b.booking_id
GROUP BY r.room_type
ORDER BY total_associated_revenue DESC;

									          # 4.5 Identify Booking and Stay Problems
-- Analytical Questions:
-- 1. Which bookings resulted in cancellations or no-shows?
SELECT 
    b.booking_id,
    g.guest_name,
    g.guest_type,
    h.hotel_name,
    h.city,
    b.booking_channel,
    b.booking_date,
    b.nights_booked,
    b.total_amount,
    s.status AS stay_status,
    s.service_requests
FROM bookings b
JOIN guests g ON b.guest_id = g.guest_id
JOIN hotels h ON b.hotel_id = h.hotel_id
JOIN stays s ON b.booking_id = s.booking_id
WHERE s.status IN ('Cancelled', 'No-show')
ORDER BY b.total_amount DESC;

-- 2. Do high service requests correlate with stay problems?
SELECT 
    CASE 
        WHEN s.service_requests = 0 THEN 'No Requests (0)'
        WHEN s.service_requests BETWEEN 1 AND 2 THEN 'Low (1-2)'
        WHEN s.service_requests BETWEEN 3 AND 5 THEN 'Medium (3-5)'
        ELSE 'High (6+)'
    END AS request_level,
    COUNT(*) AS total_stays,
    SUM(CASE WHEN s.status = 'Checked-out' THEN 1 ELSE 0 END) AS completed,
    SUM(CASE WHEN s.status = 'Cancelled' THEN 1 ELSE 0 END) AS cancelled,
    SUM(CASE WHEN s.status = 'No-show' THEN 1 ELSE 0 END) AS no_shows,
    ROUND(
        SUM(CASE WHEN s.status IN ('Cancelled', 'No-show') THEN 1 ELSE 0 END) * 100.0 / COUNT(*),
        2
    ) AS problem_rate_pct,
    AVG(b.total_amount) AS avg_booking_value
FROM stays s
JOIN bookings b ON s.booking_id = b.booking_id
GROUP BY request_level
ORDER BY problem_rate_pct DESC;

-- 3. Which hotels have the most booking problems?
SELECT 
    h.hotel_name,
    h.city,
    COUNT(*) AS total_stays,
    SUM(CASE WHEN s.status = 'Cancelled' THEN 1 ELSE 0 END) AS cancellations,
    SUM(CASE WHEN s.status = 'No-show' THEN 1 ELSE 0 END) AS no_shows,
    SUM(CASE WHEN s.status IN ('Cancelled', 'No-show') THEN 1 ELSE 0 END) AS total_problems,
    ROUND(
        SUM(CASE WHEN s.status IN ('Cancelled', 'No-show') THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 
        2
    ) AS problem_rate_pct,
    SUM(CASE WHEN s.status IN ('Cancelled', 'No-show') THEN b.total_amount ELSE 0 END) AS revenue_lost
FROM hotels h
JOIN bookings b ON h.hotel_id = b.hotel_id
JOIN stays s ON b.booking_id = s.booking_id
GROUP BY h.hotel_id, h.hotel_name, h.city
ORDER BY total_problems DESC;

-- 4. Are certain booking channels more prone to cancellations?
SELECT 
    b.booking_channel,
    COUNT(*) AS total_bookings,
    SUM(CASE WHEN s.status = 'Checked-out' THEN 1 ELSE 0 END) AS completed,
    SUM(CASE WHEN s.status = 'Cancelled' THEN 1 ELSE 0 END) AS cancelled,
    SUM(CASE WHEN s.status = 'No-show' THEN 1 ELSE 0 END) AS no_show,
    ROUND(
        SUM(CASE WHEN s.status IN ('Cancelled', 'No-show') THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 
        2
    ) AS problem_rate_pct,
    SUM(CASE WHEN s.status IN ('Cancelled', 'No-show') THEN b.total_amount ELSE 0 END) AS lost_revenue,
    AVG(b.total_amount) AS avg_booking_value
FROM bookings b
JOIN stays s ON b.booking_id = s.booking_id
GROUP BY b.booking_channel
ORDER BY problem_rate_pct DESC;

		# optional questions extra
-- Q1: Bookings That Resulted in Cancellations or No-Shows
SELECT 
    b.booking_id,
    g.guest_name,
    g.guest_type,
    h.hotel_name,
    h.city,
    b.booking_channel,
    b.booking_date,
    b.nights_booked,
    b.total_amount,
    s.status AS stay_status,
    s.service_requests
FROM bookings b
JOIN guests g ON b.guest_id = g.guest_id
JOIN hotels h ON b.hotel_id = h.hotel_id
JOIN stays s ON b.booking_id = s.booking_id
WHERE s.status IN ('Cancelled', 'No-show')
ORDER BY b.total_amount DESC;

-- Q2: Overall Stay Status Distribution & Problem Rate
SELECT 
    status,
    COUNT(*) AS stay_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS pct_of_total
FROM stays
GROUP BY status
ORDER BY stay_count DESC;

-- Q3: Service Requests vs. Stay Outcomes
SELECT 
    CASE 
        WHEN s.service_requests = 0 THEN 'No Requests'
        WHEN s.service_requests BETWEEN 1 AND 3 THEN 'Low (1-3)'
        WHEN s.service_requests BETWEEN 4 AND 6 THEN 'Medium (4-6)'
        ELSE 'High (7+)'
    END AS request_category,
    s.status,
    COUNT(*) AS stay_count,
    AVG(b.total_amount) AS avg_booking_value
FROM stays s
JOIN bookings b ON s.booking_id = b.booking_id
GROUP BY request_category, s.status
ORDER BY request_category, stay_count DESC;

-- Q4: Hotels with the Most Booking Problems

SELECT 
    h.hotel_name,
    h.city,
    COUNT(*) AS total_stays,
    SUM(CASE WHEN s.status = 'Cancelled' THEN 1 ELSE 0 END) AS cancellations,
    SUM(CASE WHEN s.status = 'No-show' THEN 1 ELSE 0 END) AS no_shows,
    SUM(CASE WHEN s.status IN ('Cancelled', 'No-show') THEN 1 ELSE 0 END) AS total_problems,
    ROUND(SUM(CASE WHEN s.status IN ('Cancelled', 'No-show') THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) 
        AS problem_rate_pct
FROM hotels h
JOIN bookings b ON h.hotel_id = b.hotel_id
JOIN stays s ON b.booking_id = s.booking_id
GROUP BY h.hotel_id, h.hotel_name, h.city
ORDER BY problem_rate_pct DESC;

-- Q5: Booking Channel Problem Analysis
SELECT 
    b.booking_channel,
    COUNT(*) AS total_bookings,
    SUM(CASE WHEN s.status = 'Checked-out' THEN 1 ELSE 0 END) AS completed,
    SUM(CASE WHEN s.status = 'Cancelled' THEN 1 ELSE 0 END) AS cancelled,
    SUM(CASE WHEN s.status = 'No-show' THEN 1 ELSE 0 END) AS no_show,
    SUM(CASE WHEN s.status = 'In-progress' THEN 1 ELSE 0 END) AS in_progress,
    ROUND(SUM(CASE WHEN s.status IN ('Cancelled', 'No-show') THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) 
        AS problem_rate_pct,
    SUM(CASE WHEN s.status IN ('Cancelled', 'No-show') THEN b.total_amount ELSE 0 END) AS lost_revenue
FROM bookings b
JOIN stays s ON b.booking_id = s.booking_id
GROUP BY b.booking_channel
ORDER BY problem_rate_pct DESC;

-- Q6: Guest Type vs. Stay Completion
SELECT 
    g.guest_type,
    COUNT(*) AS total_stays,
    SUM(CASE WHEN s.status = 'Checked-out' THEN 1 ELSE 0 END) AS completed,
    SUM(CASE WHEN s.status = 'Cancelled' THEN 1 ELSE 0 END) AS cancelled,
    SUM(CASE WHEN s.status = 'No-show' THEN 1 ELSE 0 END) AS no_shows,
    ROUND(SUM(CASE WHEN s.status IN ('Cancelled', 'No-show') THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) 
        AS problem_rate_pct,
    AVG(b.total_amount) AS avg_booking_value
FROM guests g
JOIN bookings b ON g.guest_id = b.guest_id
JOIN stays s ON b.booking_id = s.booking_id
GROUP BY g.guest_type
ORDER BY problem_rate_pct DESC;

-- Q7: Revenue Loss from Problems Over Time
SELECT 
    DATE_FORMAT(b.booking_date, '%Y-%m') AS month,
    SUM(b.total_amount) AS total_booked_revenue,
    SUM(CASE WHEN s.status IN ('Cancelled', 'No-show') THEN b.total_amount ELSE 0 END) AS lost_revenue,
    ROUND(SUM(CASE WHEN s.status IN ('Cancelled', 'No-show') THEN b.total_amount ELSE 0 END) * 100.0 
        / SUM(b.total_amount), 2) AS revenue_loss_pct
FROM bookings b
JOIN stays s ON b.booking_id = s.booking_id
GROUP BY DATE_FORMAT(b.booking_date, '%Y-%m')
ORDER BY month;

-- Q8: Room Types & Specific Rooms Associated with Problems
SELECT 
    r.room_type,
    COUNT(*) AS total_stays,
    SUM(CASE WHEN s.status IN ('Cancelled', 'No-show') THEN 1 ELSE 0 END) AS problem_stays,
    ROUND(SUM(CASE WHEN s.status IN ('Cancelled', 'No-show') THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) 
        AS problem_rate_pct,
    AVG(s.service_requests) AS avg_service_requests
FROM rooms r
LEFT JOIN stays s ON r.room_id = s.room_id
GROUP BY r.room_type
ORDER BY problem_rate_pct DESC;

-- Q9: Repeat Problem Guests (Guests with Multiple Failed Stays)
SELECT 
    g.guest_id,
    g.guest_name,
    g.guest_type,
    COUNT(*) AS total_stays,
    SUM(CASE WHEN s.status IN ('Cancelled', 'No-show') THEN 1 ELSE 0 END) AS problem_stays,
    ROUND(SUM(CASE WHEN s.status IN ('Cancelled', 'No-show') THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) 
        AS personal_problem_rate_pct,
    SUM(CASE WHEN s.status IN ('Cancelled', 'No-show') THEN b.total_amount ELSE 0 END) AS total_lost_value
FROM guests g
JOIN bookings b ON g.guest_id = b.guest_id
JOIN stays s ON b.booking_id = s.booking_id
GROUP BY g.guest_id, g.guest_name, g.guest_type
HAVING problem_stays >= 2
ORDER BY problem_stays DESC;


                                                                 # ppt questions

-- 1. Which hotels generate the most bookings?
SELECT h.hotel_name, COUNT(*) AS total_bookings,
       SUM(b.total_amount) AS revenue
FROM hotels h
JOIN bookings b ON h.hotel_id = b.hotel_id
GROUP BY h.hotel_name
ORDER BY total_bookings DESC;


-- 2. Which booking channels bring the most business?
SELECT booking_channel,
       COUNT(*) AS total_bookings,
       SUM(total_amount) AS revenue
FROM bookings
GROUP BY booking_channel
ORDER BY total_bookings DESC;

-- 3. Which room types are requested the most?
SELECT room_type_requested,
       COUNT(*) AS total_requests,
       AVG(total_amount) AS avg_amount
FROM bookings
GROUP BY room_type_requested
ORDER BY total_requests DESC;

-- 4. Which guests have the highest total spend?
SELECT g.guest_name, COUNT(*) AS bookings,
       SUM(b.total_amount) AS total_spent
FROM guests g
JOIN bookings b ON g.guest_id = b.guest_id
GROUP BY g.guest_name
ORDER BY total_spent DESC LIMIT 5;

-- 5. How do Individual and Corporate guests compare?
SELECT g.guest_type, COUNT(*) AS bookings,
       AVG(b.total_amount) AS avg_amount
FROM guests g
JOIN bookings b ON g.guest_id = b.guest_id
GROUP BY g.guest_type;


-- 6. Which bookings resulted in cancellations or no-shows?
SELECT b.booking_id, g.guest_name, g.guest_type,
       h.hotel_name, h.city,
       b.booking_channel, b.booking_date,
       b.nights_booked, b.total_amount,
       s.status, s.service_requests
FROM bookings b
JOIN guests g ON b.guest_id = g.guest_id
JOIN hotels h ON b.hotel_id = h.hotel_id
JOIN stays s ON b.booking_id = s.booking_id
WHERE s.status IN ('Cancelled','No-show')
ORDER BY b.total_amount DESC;

-- 7. Which room types are associated with more problem stays?
SELECT r.room_type,
  COUNT(*) AS total_stays,
  SUM(CASE WHEN s.status IN ('Cancelled','No-show')
           THEN 1 ELSE 0 END) AS problem_stays,
  ROUND(SUM(CASE WHEN s.status IN ('Cancelled','No-show')
           THEN 1 ELSE 0 END)*100.0/COUNT(*),2) AS problem_rate_pct,
  AVG(s.service_requests) AS avg_service_requests
FROM rooms r
LEFT JOIN stays s ON r.room_id=s.room_id
GROUP BY r.room_type
ORDER BY problem_rate_pct DESC;

-- 8. Does guest type affect stay completion and problem rates?
SELECT g.guest_type,
  COUNT(*) AS total_stays,
  SUM(CASE WHEN s.status='Checked-out' THEN 1 ELSE 0 END) AS completed,
  SUM(CASE WHEN s.status='Cancelled' THEN 1 ELSE 0 END) AS cancelled,
  SUM(CASE WHEN s.status='No-show' THEN 1 ELSE 0 END) AS no_shows,
  ROUND(SUM(CASE WHEN s.status IN ('Cancelled','No-show')
           THEN 1 ELSE 0 END)*100.0/COUNT(*),2) AS problem_rate_pct,
  AVG(b.total_amount) AS avg_booking_value
FROM guests g
JOIN bookings b ON g.guest_id=b.guest_id
JOIN stays s ON b.booking_id=s.booking_id
GROUP BY g.guest_type
ORDER BY problem_rate_pct DESC;

-- 9. Which hotels have the most booking problems?
SELECT h.hotel_name, h.city,
  COUNT(*) AS total_stays,
  SUM(CASE WHEN s.status='Cancelled' THEN 1 ELSE 0 END) AS cancellations,
  SUM(CASE WHEN s.status='No-show' THEN 1 ELSE 0 END) AS no_shows,
  SUM(CASE WHEN s.status IN ('Cancelled','No-show')
           THEN 1 ELSE 0 END) AS total_problems,
  ROUND(SUM(CASE WHEN s.status IN ('Cancelled','No-show')
           THEN 1 ELSE 0 END)*100.0/COUNT(*),2) AS problem_rate_pct,
  SUM(CASE WHEN s.status IN ('Cancelled','No-show')
           THEN b.total_amount ELSE 0 END) AS revenue_lost
FROM hotels h
JOIN bookings b ON h.hotel_id=b.hotel_id
JOIN stays s ON b.booking_id=s.booking_id
GROUP BY h.hotel_id, h.hotel_name, h.city
ORDER BY total_problems DESC;

 -- 10. Hotel stay success rate (Checked-out vs problems)
SELECT 
    h.hotel_name,
    COUNT(*) AS total_stays,
    SUM(CASE WHEN s.status = 'Checked-out' THEN 1 ELSE 0 END) AS completed_stays,
    SUM(CASE WHEN s.status IN ('No-show', 'Cancelled') THEN 1 ELSE 0 END) AS problem_stays,
    ROUND(SUM(CASE WHEN s.status = 'Checked-out' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS completion_rate
FROM hotels h
JOIN bookings b ON h.hotel_id = b.hotel_id
JOIN stays s ON b.booking_id = s.booking_id
GROUP BY h.hotel_id, h.hotel_name
ORDER BY completion_rate ASC;




                                 -- 6. Final Conclusions & Recommendations
-- 1. Operational Focus: Identify the top 2-3 hotels with the highest problem rates and conduct on-site operational reviews.
-- 2. Channel Strategy: Shift marketing budget toward channels with high completion rates; renegotiate terms with high-cancellation channels.
-- 3. Revenue Protection: Implement deposit or pre-payment requirements for booking channels and guest types with high no-show rates.
-- 4. Staff Development: Use staff rating and stay outcome data to create targeted training for low-performing staff and reward high performers.
-- 5. Room Maintenance: Flag individual rooms with repeated problems for immediate inspection and maintenance.
-- 6. Guest Retention: Create a loyalty outreach program for repeat guests with zero problems, and require confirmation calls for repeat problem guests.