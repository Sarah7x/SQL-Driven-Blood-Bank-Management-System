-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Feb 17, 2024 at 11:42 PM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `blood_bank_system`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `ExecuteAndAnalyzeQueries` ()   BEGIN
    CREATE TEMPORARY TABLE temp_results (
        QueryType VARCHAR(255),
        blood_group VARCHAR(3),
        TotalUnits INT
    );

    -- Blood Inventory Distribution
    INSERT INTO temp_results (QueryType, blood_group, TotalUnits)
    SELECT 'Inventory Distribution', blood_group, SUM(units_available)
    FROM blood_inventory
    GROUP BY blood_group;

    -- Potential Donors
    INSERT INTO temp_results (QueryType, blood_group, TotalUnits)
    SELECT 'Potential Donors', blood_group, COUNT(donor_id)
    FROM donors
    WHERE last_donation_date <= CURDATE() - INTERVAL 6 MONTH
    GROUP BY blood_group;

    -- Blood Unit Lifecycle
    INSERT INTO temp_results (QueryType, blood_group, TotalUnits)
    SELECT 'Unit Lifecycle', blood_group, COUNT(inventory_id)
    FROM blood_inventory
    WHERE expiration_date <= CURDATE() + INTERVAL 30 DAY
    GROUP BY blood_group;

    SELECT * FROM temp_results;
    DROP TEMPORARY TABLE IF EXISTS temp_results;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `audit_log`
--

CREATE TABLE `audit_log` (
  `audit_id` int(11) NOT NULL COMMENT 'Unique identifier for each audit log entry',
  `table_name` varchar(255) NOT NULL COMMENT 'Name of the table where the change occurred',
  `column_name` varchar(255) DEFAULT NULL COMMENT 'Name of the column that was changed',
  `record_id` int(11) NOT NULL COMMENT 'ID of the record in the original table that was changed',
  `action` enum('INSERT','UPDATE','DELETE') NOT NULL COMMENT 'Type of action performed',
  `previous_value` text DEFAULT NULL COMMENT 'Previous value of the data, mainly for UPDATE actions',
  `new_value` text DEFAULT NULL COMMENT 'New value of the data, mainly for INSERT and UPDATE actions',
  `changed_by` varchar(255) NOT NULL COMMENT 'Identifier of the user who made the change',
  `changed_at` datetime DEFAULT current_timestamp() COMMENT 'Timestamp when the change was made'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Centralized table to record audit logs for data changes across various tables';

-- --------------------------------------------------------

--
-- Table structure for table `blood_inventory`
--

CREATE TABLE `blood_inventory` (
  `inventory_id` int(10) UNSIGNED NOT NULL COMMENT 'Unique identifier for inventory items',
  `donation_id` int(10) UNSIGNED DEFAULT NULL COMMENT 'Reference to the donation from which this blood unit originated',
  `blood_group` varchar(3) NOT NULL COMMENT 'Blood group category',
  `units_available` int(10) UNSIGNED NOT NULL COMMENT 'Number of units available',
  `quality` enum('Good','Contaminated') NOT NULL DEFAULT 'Good' COMMENT 'Quality status of the blood',
  `status` enum('stored','tested','distributed','discarded') NOT NULL DEFAULT 'stored' COMMENT 'Current status of the blood unit',
  `date_received` date NOT NULL COMMENT 'The date when the blood unit was received',
  `expiration_date` date NOT NULL COMMENT 'The expiration date for the blood unit, after which it cannot be used',
  `temperature` decimal(3,1) NOT NULL COMMENT 'Storage temperature of the blood unit in Celsius',
  `volume` int(10) UNSIGNED NOT NULL COMMENT 'Volume of the blood unit in milliliters (ml)',
  `recipient_id` int(10) UNSIGNED DEFAULT NULL
) ;

--
-- Dumping data for table `blood_inventory`
--

INSERT INTO `blood_inventory` (`inventory_id`, `donation_id`, `blood_group`, `units_available`, `quality`, `status`, `date_received`, `expiration_date`, `temperature`, `volume`, `recipient_id`) VALUES
(1, 1, 'A+', 10, 'Good', 'stored', '2024-01-01', '2024-06-01', 4.0, 500, NULL),
(2, 2, 'O-', 8, 'Good', 'tested', '2024-01-05', '2024-06-05', 4.0, 450, NULL),
(3, 3, 'B+', 15, 'Good', 'stored', '2024-01-10', '2024-06-10', 4.0, 500, NULL),
(4, 4, 'AB-', 5, 'Contaminated', 'discarded', '2024-01-15', '2024-06-15', 4.0, 400, NULL),
(5, 5, 'A-', 7, 'Good', 'distributed', '2024-01-20', '2024-06-20', 4.0, 350, 3),
(6, 6, 'B-', 9, 'Good', 'tested', '2024-01-25', '2024-06-25', 4.0, 500, NULL),
(7, 7, 'O+', 12, 'Good', 'stored', '2024-01-25', '2024-06-25', 4.0, 500, NULL),
(8, 8, 'AB+', 6, 'Good', 'stored', '2024-01-25', '2024-06-25', 4.0, 450, NULL),
(9, 9, 'A+', 11, 'Good', 'stored', '2024-02-01', '2024-07-01', 4.0, 550, NULL),
(10, 10, 'O-', 5, 'Good', 'distributed', '2024-02-01', '2024-07-01', 4.0, 300, 4),
(11, 11, 'B+', 14, 'Good', 'stored', '2024-02-05', '2024-07-05', 4.0, 520, NULL),
(12, 12, 'AB-', 4, 'Contaminated', 'discarded', '2024-02-05', '2024-07-05', 4.0, 400, NULL),
(13, 13, 'A-', 6, 'Good', 'tested', '2024-02-05', '2024-07-05', 4.0, 350, NULL),
(14, 14, 'B-', 10, 'Good', 'stored', '2024-02-05', '2024-07-05', 4.0, 500, NULL),
(15, 15, 'O+', 13, 'Good', 'stored', '2024-02-05', '2024-07-05', 4.0, 530, NULL),
(16, 16, 'AB+', 7, 'Good', 'tested', '2024-02-05', '2024-07-05', 4.0, 470, NULL);

-- --------------------------------------------------------

--
-- Stand-in structure for view `blood_stock_levels`
-- (See below for the actual view)
--
CREATE TABLE `blood_stock_levels` (
`blood_group` varchar(3)
,`quality` enum('Good','Contaminated')
,`status` enum('stored','tested','distributed','discarded')
,`total_units` decimal(32,0)
);

-- --------------------------------------------------------

--
-- Table structure for table `blood_tests`
--

CREATE TABLE `blood_tests` (
  `test_id` int(10) UNSIGNED NOT NULL COMMENT 'Unique identifier for each blood test',
  `donor_id` int(10) UNSIGNED NOT NULL COMMENT 'References the donor''s unique identifier',
  `technician_id` int(10) UNSIGNED DEFAULT NULL COMMENT 'References the technician responsible for the test',
  `date` date NOT NULL COMMENT 'Date the test was performed',
  `disease_tested` varchar(255) NOT NULL COMMENT 'Name of the disease tested',
  `result` enum('Positive','Negative') DEFAULT NULL COMMENT 'Result of the test',
  `test_type` varchar(255) NOT NULL COMMENT 'The type of test performed, such as blood typing or disease screening',
  `comments` text DEFAULT NULL COMMENT 'Additional observations or notes about the test'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='Contains results of blood tests performed on donors';

--
-- Dumping data for table `blood_tests`
--

INSERT INTO `blood_tests` (`test_id`, `donor_id`, `technician_id`, `date`, `disease_tested`, `result`, `test_type`, `comments`) VALUES
(61, 1, 3, '2020-10-16', '', 'Positive', 'Blood Typing', 'Blood type A+'),
(62, 2, 4, '2021-01-21', 'HIV', 'Negative', 'Disease Screening', 'Clear of HIV'),
(63, 3, 3, '2021-02-19', '', 'Positive', 'Blood Typing', 'Blood type B+'),
(64, 4, 17, '2020-12-06', 'Hepatitis B', 'Negative', 'Disease Screening', 'No hepatitis B detected'),
(65, 5, 9, '2021-03-11', '', 'Positive', 'General Health', 'No health issues found'),
(66, 6, 6, '2020-09-23', 'HIV', 'Negative', 'Disease Screening', 'No HIV'),
(67, 7, 20, '2020-11-13', '', 'Positive', 'Blood Typing', 'Blood type O-'),
(68, 8, 9, '2021-01-31', 'Hepatitis B', 'Negative', 'Disease Screening', 'No issues detected'),
(69, 9, 16, '2020-08-20', '', 'Positive', 'General Health', 'Healthy donor'),
(70, 10, 11, '2021-03-06', 'HIV', 'Negative', 'Disease Screening', 'Negative result'),
(71, 11, 13, '2020-07-12', '', 'Positive', 'Blood Typing', 'Blood type AB+'),
(72, 12, 14, '2021-02-06', 'Hepatitis B', 'Negative', 'Disease Screening', 'Test is clear'),
(73, 13, 15, '2020-10-29', '', 'Positive', 'General Health', 'Good health'),
(74, 14, 5, '2021-04-10', 'HIV', 'Negative', 'Disease Screening', 'HIV test negative'),
(75, 15, 5, '2020-08-31', '', 'Positive', 'Blood Typing', 'Blood type A-'),
(76, 16, 7, '2021-01-16', 'Hepatitis B', 'Negative', 'Disease Screening', 'Negative for hepatitis B'),
(77, 17, 7, '2020-11-21', '', 'Positive', 'General Health', 'No health issues'),
(78, 18, 7, '2021-03-21', 'HIV', 'Negative', 'Disease Screening', 'All clear'),
(79, 19, 16, '2020-09-06', '', 'Positive', 'Blood Typing', 'Blood type O+'),
(80, 20, 16, '0000-00-00', 'Hepatitis B', 'Negative', 'Disease Screening', 'Hepatitis B not detected');

-- --------------------------------------------------------

--
-- Table structure for table `blood_type_compatibility`
--

CREATE TABLE `blood_type_compatibility` (
  `donor_blood_type` varchar(3) DEFAULT NULL,
  `recipient_blood_type` varchar(3) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `blood_type_compatibility`
--

INSERT INTO `blood_type_compatibility` (`donor_blood_type`, `recipient_blood_type`) VALUES
('A+', 'A+'),
('A+', 'AB+'),
('O+', 'A+'),
('O+', 'O+'),
('O+', 'AB+'),
('O+', 'B+');

-- --------------------------------------------------------

--
-- Table structure for table `donations`
--

CREATE TABLE `donations` (
  `donation_id` int(10) UNSIGNED NOT NULL COMMENT 'Unique identifier for each donation',
  `donor_id` int(10) UNSIGNED DEFAULT NULL COMMENT 'Identifier of the donor who made this donation',
  `hospital_id` int(10) UNSIGNED DEFAULT NULL COMMENT 'Identifier of the hospital where this donation took place',
  `recipient_id` int(10) UNSIGNED DEFAULT NULL COMMENT 'Identifier of the recipient for this donation, if applicable',
  `collection_technician_id` int(10) UNSIGNED DEFAULT NULL COMMENT 'Identifier of the technician who collected this donation',
  `processed_by_technician_id` int(10) UNSIGNED DEFAULT NULL COMMENT 'Identifier of the technician who processed this donation',
  `test_result_id` int(10) UNSIGNED DEFAULT NULL COMMENT 'Identifier of the test result associated with this donation',
  `date` date NOT NULL COMMENT 'Date of the donation',
  `quantity` int(10) UNSIGNED NOT NULL COMMENT 'Quantity of blood donated',
  `blood_group` varchar(3) NOT NULL COMMENT 'Blood group of the donated blood',
  `status` enum('pending','complete','tested','distributed') NOT NULL DEFAULT 'pending' COMMENT 'The current status of the donation',
  `bag_serial_number` varchar(255) DEFAULT NULL COMMENT 'References the ID of the collection technician',
  `storage_temperature` decimal(10,0) DEFAULT NULL COMMENT 'Temperature at which the blood was stored',
  `expiration_date` date NOT NULL COMMENT 'The date when the blood is no longer usable',
  `donation_type` enum('whole_blood','platelets','plasma') DEFAULT NULL COMMENT 'Type of donation'
) ;

--
-- Dumping data for table `donations`
--

INSERT INTO `donations` (`donation_id`, `donor_id`, `hospital_id`, `recipient_id`, `collection_technician_id`, `processed_by_technician_id`, `test_result_id`, `date`, `quantity`, `blood_group`, `status`, `bag_serial_number`, `storage_temperature`, `expiration_date`, `donation_type`) VALUES
(1, 1, NULL, NULL, NULL, 3, NULL, '2020-10-15', 500, 'A+', 'complete', 'BAG1001', 4, '2021-04-15', 'whole_blood'),
(2, 2, NULL, NULL, NULL, 3, NULL, '2021-01-20', 450, 'O-', 'complete', 'BAG1002', 4, '2021-07-20', 'whole_blood'),
(3, 3, NULL, NULL, NULL, 3, NULL, '2021-02-18', 480, 'B+', 'complete', 'BAG1003', 4, '2021-08-18', 'plasma'),
(4, 4, NULL, NULL, NULL, 3, NULL, '2020-12-05', 470, 'AB-', 'complete', 'BAG1004', 4, '2021-06-05', 'platelets'),
(5, 5, NULL, NULL, NULL, 5, NULL, '2021-03-10', 510, 'A-', 'complete', 'BAG1005', 4, '2021-09-10', 'whole_blood'),
(6, 6, NULL, NULL, NULL, 5, NULL, '2020-09-22', 500, 'B-', 'complete', 'BAG1006', 4, '2021-03-22', 'whole_blood'),
(7, 7, NULL, NULL, NULL, 5, NULL, '2020-11-12', 480, 'O+', 'complete', 'BAG1007', 4, '2021-05-12', 'plasma'),
(8, 8, NULL, NULL, NULL, 5, NULL, '2021-01-30', 470, 'AB+', 'complete', 'BAG1008', 4, '2021-07-30', 'platelets'),
(9, 9, NULL, NULL, NULL, 3, NULL, '2020-08-19', 510, 'A+', 'complete', 'BAG1009', 0, '2021-02-19', 'whole_blood'),
(10, 10, NULL, NULL, NULL, 3, NULL, '2021-03-05', 500, 'B+', 'complete', 'BAG1010', 4, '2021-09-05', 'whole_blood'),
(11, 11, NULL, NULL, NULL, 3, NULL, '2020-07-11', 480, 'O-', 'complete', 'BAG1011', 4, '2021-01-11', 'plasma'),
(12, 12, NULL, NULL, NULL, 3, NULL, '2021-02-05', 470, 'A-', 'complete', 'BAG1012', 4, '2021-08-05', 'platelets'),
(13, 13, NULL, NULL, NULL, 3, NULL, '2020-10-28', 510, 'AB-', 'complete', 'BAG1013', 4, '2021-04-28', 'whole_blood'),
(14, 14, NULL, NULL, NULL, 3, NULL, '2021-04-09', 500, 'B-', 'complete', 'BAG1014', 4, '2021-10-09', 'whole_blood'),
(15, 15, NULL, NULL, NULL, 3, NULL, '2020-08-30', 480, 'O+', 'complete', 'BAG1015', 4, '2021-02-28', 'plasma'),
(16, 16, NULL, NULL, NULL, 3, NULL, '2021-01-15', 470, 'A+', 'complete', 'BAG1016', 4, '2021-07-15', 'platelets'),
(17, 17, NULL, NULL, NULL, 3, NULL, '2020-11-20', 510, 'AB+', 'complete', 'BAG1017', 4, '2021-05-20', 'whole_blood'),
(18, 18, NULL, NULL, NULL, 3, NULL, '2021-03-20', 500, 'B+', 'complete', 'BAG1018', 4, '2021-09-20', 'whole_blood'),
(19, 19, NULL, NULL, NULL, 3, NULL, '2020-09-05', 480, 'O-', 'complete', 'BAG1019', 4, '2021-03-05', 'plasma'),
(20, 20, NULL, NULL, NULL, 3, NULL, '2021-02-25', 470, 'A-', 'complete', 'BAG1020', 4, '2021-08-25', 'platelets'),
(21, 1, NULL, NULL, NULL, 4, NULL, '2024-02-10', 500, 'A+', '', NULL, NULL, '0000-00-00', NULL),
(22, 2, NULL, NULL, NULL, 4, NULL, '2024-02-20', 450, 'O-', '', NULL, NULL, '0000-00-00', NULL),
(23, 3, 3, NULL, NULL, 4, NULL, '2024-02-15', 480, 'B+', '', NULL, NULL, '0000-00-00', NULL),
(24, 1, NULL, NULL, NULL, 4, NULL, '2024-02-10', 500, 'A+', '', NULL, NULL, '2024-03-13', NULL),
(25, 2, NULL, NULL, NULL, 4, NULL, '2024-02-20', 450, 'O-', '', NULL, NULL, '2024-03-13', NULL),
(26, 3, 3, NULL, NULL, 4, NULL, '2024-02-15', 480, 'B+', '', NULL, NULL, '2024-03-13', NULL),
(27, 4, 4, NULL, NULL, 4, NULL, '2024-02-05', 470, 'AB-', '', NULL, NULL, '2024-03-13', NULL),
(28, 5, 5, NULL, NULL, 4, NULL, '2024-02-12', 500, 'A-', '', NULL, NULL, '2024-03-13', NULL),
(29, 6, NULL, NULL, NULL, 4, NULL, '2024-02-07', 450, 'B-', '', NULL, NULL, '2024-03-13', NULL),
(30, 7, NULL, NULL, NULL, 4, NULL, '2024-02-14', 480, 'O+', '', NULL, NULL, '2024-03-13', NULL),
(31, 8, 3, NULL, NULL, 4, NULL, '2024-02-21', 500, 'AB+', '', NULL, NULL, '2024-03-13', NULL),
(32, 9, 4, NULL, NULL, 4, NULL, '2024-02-18', 470, 'A+', '', NULL, NULL, '2024-03-13', NULL),
(33, 10, 5, NULL, NULL, 4, NULL, '2024-02-25', 450, 'O-', '', NULL, NULL, '2024-03-13', NULL),
(34, 11, NULL, NULL, NULL, 4, NULL, '2024-02-28', 480, 'B+', '', NULL, NULL, '2024-03-13', NULL),
(35, 12, NULL, NULL, NULL, 4, NULL, '2024-02-03', 500, 'AB-', '', NULL, NULL, '2024-03-13', NULL),
(36, 13, 3, NULL, NULL, 4, NULL, '2024-02-11', 450, 'A-', '', NULL, NULL, '2024-03-13', NULL),
(37, 14, 4, NULL, NULL, 4, NULL, '2024-02-17', 480, 'B-', '', NULL, NULL, '2024-03-13', NULL),
(38, 15, 5, NULL, NULL, 4, NULL, '2024-02-22', 500, 'O+', '', NULL, NULL, '2024-03-13', NULL),
(39, 16, NULL, NULL, NULL, 4, NULL, '2024-02-26', 470, 'AB+', '', NULL, NULL, '2024-03-13', NULL),
(40, 17, NULL, NULL, NULL, 4, NULL, '2024-02-08', 450, 'A+', '', NULL, NULL, '2024-03-13', NULL),
(41, 18, 3, NULL, NULL, 5, NULL, '2024-02-16', 480, 'O-', '', NULL, NULL, '2024-03-13', NULL),
(42, 19, 4, NULL, NULL, 5, NULL, '2024-02-19', 500, 'B+', '', NULL, NULL, '2024-03-13', NULL),
(43, 20, 5, NULL, NULL, 5, NULL, '2024-02-23', 470, 'AB-', '', NULL, NULL, '2024-03-13', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `donors`
--

CREATE TABLE `donors` (
  `donor_id` int(10) UNSIGNED NOT NULL COMMENT 'Unique identifier for each donor',
  `registered_by_staff_id` int(10) UNSIGNED DEFAULT NULL COMMENT 'Identifier for the staff member who registered this donor',
  `primary_contact_id` int(10) UNSIGNED DEFAULT NULL COMMENT 'Identifier for the primary contact of this donor',
  `name` varchar(255) NOT NULL COMMENT 'Full name of the donor',
  `age` int(10) UNSIGNED NOT NULL COMMENT 'Age of the donor',
  `gender` enum('Male','Female','Other') NOT NULL COMMENT 'Gender of the donor',
  `weight` decimal(5,2) DEFAULT NULL COMMENT 'Weight of the donor in kilograms',
  `blood_group` varchar(3) NOT NULL COMMENT 'Blood group of the donor',
  `last_donation_date` date DEFAULT NULL COMMENT 'The last date the donor donated blood',
  `is_eligible` tinyint(1) UNSIGNED NOT NULL DEFAULT 0 COMMENT 'Whether the donor is currently eligible to donate',
  `donations_count` int(10) UNSIGNED DEFAULT 0 COMMENT 'Total number of donations made by the donor',
  `contact_method_type` enum('phone','email') NOT NULL DEFAULT 'phone' COMMENT 'Preferred contact method of the donor',
  `contact_detail` varchar(255) DEFAULT NULL COMMENT 'Contact detail corresponding to the selected contact method',
  `donor_type` enum('individual','corporation','anonymous') DEFAULT 'individual' COMMENT 'Type of donor',
  `notes` text DEFAULT NULL COMMENT 'Additional notes about the donor',
  `last_health_check_date` date DEFAULT NULL COMMENT 'Date of the last health check for the donor',
  `donation_frequency_allowed` int(10) UNSIGNED DEFAULT NULL COMMENT 'Frequency of donations allowed per year',
  `location` varchar(255) DEFAULT NULL COMMENT 'Geographical location of the donor',
  `days_since_last_donation` int(11) DEFAULT NULL COMMENT 'Calculated days since the last donation',
  `blood_group_A_plus` tinyint(1) DEFAULT 0,
  `blood_group_O_minus` tinyint(1) DEFAULT 0,
  `blood_group_B_plus` tinyint(1) DEFAULT 0,
  `blood_group_AB_minus` tinyint(1) DEFAULT 0,
  `blood_group_A_minus` tinyint(1) DEFAULT 0,
  `blood_group_B_minus` tinyint(1) DEFAULT 0,
  `blood_group_O_plus` tinyint(1) DEFAULT 0,
  `blood_group_AB_plus` tinyint(1) DEFAULT 0
) ;

--
-- Dumping data for table `donors`
--

INSERT INTO `donors` (`donor_id`, `registered_by_staff_id`, `primary_contact_id`, `name`, `age`, `gender`, `weight`, `blood_group`, `last_donation_date`, `is_eligible`, `donations_count`, `contact_method_type`, `contact_detail`, `donor_type`, `notes`, `last_health_check_date`, `donation_frequency_allowed`, `location`, `days_since_last_donation`, `blood_group_A_plus`, `blood_group_O_minus`, `blood_group_B_plus`, `blood_group_AB_minus`, `blood_group_A_minus`, `blood_group_B_minus`, `blood_group_O_plus`, `blood_group_AB_plus`) VALUES
(1, NULL, NULL, 'John Doe', 35, 'Male', 70.50, 'A+', '2020-10-15', 1, 5, 'phone', '514-123-4567', 'individual', 'Regular donor', '2020-10-01', 2, 'Montreal', 1209, 1, 0, 0, 0, 0, 0, 0, 0),
(2, NULL, NULL, 'Jane Smith', 29, 'Female', 65.20, 'O-', '2021-01-20', 1, 3, 'email', 'jane.smith@email.com', 'individual', 'New donor', '2021-01-10', 1, 'Quebec City', 1112, 0, 1, 0, 0, 0, 0, 0, 0),
(3, NULL, NULL, 'Alice Johnson', 42, 'Female', 58.30, 'B+', '2021-02-18', 1, 4, 'email', 'alice.johnson@email.com', 'individual', 'Frequent donor', '2021-02-01', 2, 'Laval', 1083, 0, 0, 1, 0, 0, 0, 0, 0),
(4, NULL, NULL, 'Michael Brown', 31, 'Male', 80.70, 'AB-', '2020-12-05', 1, 2, 'phone', '514-234-5678', 'individual', 'Occasional donor', '2020-11-20', 1, 'Sherbrooke', 1158, 0, 0, 0, 1, 0, 0, 0, 0),
(5, NULL, NULL, 'Emily Wilson', 26, 'Female', 54.10, 'A-', '2021-03-10', 1, 1, 'phone', '514-345-6789', 'individual', 'First-time donor', '2021-03-01', 1, 'Gatineau', 1063, 0, 0, 0, 0, 1, 0, 0, 0),
(6, NULL, NULL, 'Chris Green', 38, 'Male', 77.40, 'B-', '2020-09-22', 1, 4, 'email', 'chris.green@email.com', 'individual', 'Regular donor', '2020-09-10', 2, 'Longueuil', 1232, 0, 0, 0, 0, 0, 1, 0, 0),
(7, NULL, NULL, 'Olivia Harris', 33, 'Female', 60.60, 'O+', '2020-11-12', 1, 2, 'phone', '514-456-7890', 'individual', 'Occasional donor', '2020-11-01', 1, 'Trois-Rivières', 1181, 0, 0, 0, 0, 0, 0, 1, 0),
(8, NULL, NULL, 'Daniel White', 45, 'Male', 85.50, 'AB+', '2021-01-30', 1, 6, 'phone', '514-567-8901', 'individual', 'Frequent donor', '2021-01-15', 2, 'Drummondville', 1102, 0, 0, 0, 0, 0, 0, 0, 1),
(9, NULL, NULL, 'Sophia Martinez', 37, 'Female', 68.00, 'A+', '2020-08-19', 1, 3, 'email', 'sophia.martinez@email.com', 'individual', 'Regular donor', '2020-08-05', 1, 'Brossard', 1266, 1, 0, 0, 0, 0, 0, 0, 0),
(10, NULL, NULL, 'David Taylor', 50, 'Male', 90.30, 'B+', '2021-03-05', 1, 5, 'email', 'david.taylor@email.com', 'individual', 'Frequent donor', '2021-02-20', 2, 'Blainville', 1068, 0, 0, 1, 0, 0, 0, 0, 0),
(11, NULL, NULL, 'Linda Scott', 27, 'Female', 62.80, 'O-', '2020-07-11', 1, 1, 'phone', '514-678-9012', 'individual', 'New donor', '2020-06-30', 1, 'Saint-Jean-sur-Richelieu', 1305, 0, 1, 0, 0, 0, 0, 0, 0),
(12, NULL, NULL, 'Robert King', 39, 'Male', 75.40, 'A-', '2021-02-05', 1, 2, 'email', 'robert.king@email.com', 'individual', 'Occasional donor', '2021-01-22', 1, 'Granby', 1096, 0, 0, 0, 0, 1, 0, 0, 0),
(13, NULL, NULL, 'Maria Garcia', 34, 'Female', 59.70, 'AB-', '2020-10-28', 1, 3, 'phone', '514-789-0123', 'individual', 'Regular donor', '2020-10-15', 1, 'Repentigny', 1196, 0, 0, 0, 1, 0, 0, 0, 0),
(14, NULL, NULL, 'James Wilson', 48, 'Male', 82.60, 'B-', '2021-04-09', 1, 4, 'email', 'james.wilson@email.com', 'individual', 'Frequent donor', '2021-03-25', 2, 'Mascouche', 1033, 0, 0, 0, 0, 0, 1, 0, 0),
(15, NULL, NULL, 'Patricia Davis', 30, 'Female', 57.90, 'A+', '2020-08-30', 1, 1, 'phone', '514-890-1234', 'individual', 'First-time donor', '2020-08-15', 1, 'Côte-Saint-Luc', 1255, 1, 0, 0, 0, 0, 0, 0, 0),
(16, NULL, NULL, 'Charles Miller', 52, 'Male', 88.10, 'O+', '2021-01-15', 1, 3, 'email', 'charles.miller@email.com', 'individual', 'Occasional donor', '2020-12-31', 1, 'Dollard-Des Ormeaux', 1117, 0, 0, 0, 0, 0, 0, 1, 0),
(17, NULL, NULL, 'Jennifer Lee', 46, 'Female', 66.40, 'AB+', '2020-11-20', 1, 2, 'phone', '514-901-2345', 'individual', 'Regular donor', '2020-11-05', 1, 'Pointe-Claire', 1173, 0, 0, 0, 0, 0, 0, 0, 1),
(18, NULL, NULL, 'Kevin Harris', 41, 'Male', 78.50, 'B+', '2021-03-20', 1, 4, 'email', 'kevin.harris@email.com', 'individual', 'Frequent donor', '2021-03-05', 2, 'Dorval', 1053, 0, 0, 1, 0, 0, 0, 0, 0),
(19, NULL, NULL, 'Laura Moore', 28, 'Female', 63.30, 'A-', '2020-09-05', 1, 1, 'phone', '514-012-3456', 'individual', 'New donor', '2020-08-20', 1, 'Kirkland', 1249, 0, 0, 0, 0, 1, 0, 0, 0),
(20, NULL, NULL, 'Brian Jackson', 36, 'Male', 76.20, 'O-', '2021-02-25', 1, 5, 'email', 'brian.jackson@email.com', 'individual', 'Occasional donor', '2021-02-10', 1, 'Beaconsfield', 1076, 0, 1, 0, 0, 0, 0, 0, 0),
(21, NULL, NULL, 'Alex Tremblay', 32, 'Male', 78.30, 'A-', '2023-01-15', 1, 2, 'email', 'alex.tremblay@email.com', 'individual', 'Occasional donor', '2023-01-05', 2, 'Montreal', 22, 0, 0, 0, 0, 1, 0, 0, 0),
(22, NULL, NULL, 'Marie-Claire Séguin', 27, 'Female', 65.10, 'O+', '2023-02-20', 1, 4, 'phone', '514-658-2145', 'individual', 'New donor', '2023-02-10', 1, 'Quebec City', 17, 0, 0, 0, 0, 0, 0, 1, 0),
(23, NULL, NULL, 'Étienne Gagnon', 46, 'Male', 84.50, 'B+', '2022-11-25', 1, 5, 'email', 'etienne.gagnon@email.com', 'individual', 'Regular donor', '2022-11-15', 2, 'Laval', 73, 0, 0, 1, 0, 0, 0, 0, 0),
(24, NULL, NULL, 'Sophie Lavoie', 39, 'Female', 59.70, 'AB-', '2023-01-29', 1, 3, 'phone', '418-965-7894', 'individual', 'Frequent donor', '2023-01-19', 1, 'Sherbrooke', 39, 0, 0, 0, 1, 0, 0, 0, 0),
(25, NULL, NULL, 'Lucas Dupont', 31, 'Male', 76.20, 'O-', '2023-03-05', 1, 6, 'email', 'lucas.dupont@email.com', 'individual', 'First-time donor', '2023-02-23', 2, 'Gatineau', 5, 0, 1, 0, 0, 0, 0, 0, 0),
(26, NULL, NULL, 'Gabrielle Mercier', 34, 'Female', 62.40, 'A+', '2022-12-15', 1, 7, 'phone', '514-234-5678', 'individual', 'Active donor', '2022-12-05', 2, 'Longueuil', 53, 1, 0, 0, 0, 0, 0, 0, 0),
(27, NULL, NULL, 'Jean-Francois Morin', 29, 'Male', 82.30, 'B-', '2023-02-28', 1, 3, 'email', 'jf.morin@email.com', 'individual', 'First-time donor', '2023-02-18', 1, 'Trois-Rivières', 9, 0, 0, 0, 0, 0, 1, 0, 0),
(28, NULL, NULL, 'Charlotte Giroux', 37, 'Female', 67.50, 'AB+', '2022-10-30', 1, 6, 'phone', '514-789-0123', 'individual', 'Occasional donor', '2022-10-20', 2, 'Drummondville', 99, 0, 0, 0, 0, 0, 0, 0, 1),
(29, NULL, NULL, 'Olivier Roy', 41, 'Male', 90.10, 'A+', '2022-12-10', 1, 2, 'email', 'olivier.roy@email.com', 'individual', 'Regular donor', '2022-11-30', 1, 'Brossard', 58, 1, 0, 0, 0, 0, 0, 0, 0),
(30, NULL, NULL, 'Isabelle Simard', 25, 'Female', 54.20, 'O-', '2023-01-12', 1, 4, 'phone', '418-324-5678', 'individual', 'New donor', '2023-01-02', 1, 'Blainville', 25, 0, 1, 0, 0, 0, 0, 0, 0),
(31, NULL, NULL, 'Marc-Andre Fortin', 33, 'Male', 77.80, 'B+', '2023-03-10', 1, 7, 'email', 'ma.fortin@email.com', 'individual', 'Active donor', '2023-02-28', 2, 'Saint-Jean-sur-Richelieu', 1, 0, 0, 1, 0, 0, 0, 0, 0),
(32, NULL, NULL, 'Julie Tremblay', 30, 'Female', 63.00, 'A-', '2022-11-20', 1, 5, 'phone', '514-123-4567', 'individual', 'Frequent donor', '2022-11-10', 2, 'Granby', 78, 0, 0, 0, 0, 1, 0, 0, 0),
(33, NULL, NULL, 'Francois Lévesque', 48, 'Male', 85.40, 'AB-', '2022-09-15', 1, 1, 'email', 'francois.levesque@email.com', 'individual', 'Long-time donor', '2022-09-05', 1, 'Repentigny', 144, 0, 0, 0, 1, 0, 0, 0, 0),
(34, NULL, NULL, 'Anne-Marie Côté', 42, 'Female', 70.60, 'O+', '2023-02-05', 1, 3, 'phone', '418-567-8901', 'individual', 'Dedicated donor', '2023-01-26', 1, 'Mascouche', 32, 0, 0, 0, 0, 0, 0, 1, 0),
(35, NULL, NULL, 'Rémi Bouchard', 36, 'Male', 73.20, 'B-', '2023-01-08', 1, 2, 'email', 'remi.bouchard@email.com', 'individual', 'Occasional donor', '2022-12-29', 2, 'Côte-Saint-Luc', 59, 0, 0, 0, 0, 0, 1, 0, 0),
(36, NULL, NULL, 'Catherine Leclerc', 28, 'Female', 61.90, 'A+', '2022-10-22', 1, 4, 'phone', '514-234-7890', 'individual', 'First-time donor', '2022-10-12', 1, 'Dollard-Des Ormeaux', 137, 1, 0, 0, 0, 0, 0, 0, 0),
(37, NULL, NULL, 'Guillaume Prévost', 45, 'Male', 88.70, 'AB+', '2022-12-30', 1, 6, 'email', 'guillaume.prevost@email.com', 'individual', 'Regular donor', '2022-12-20', 2, 'Pointe-Claire', 38, 0, 0, 0, 0, 0, 0, 0, 1),
(38, NULL, NULL, 'Nathalie Dion', 34, 'Female', 58.40, 'O-', '2023-03-15', 1, 7, 'phone', '418-345-6789', 'individual', 'Active donor', '2023-03-05', 1, 'Dorval', 0, 0, 1, 0, 0, 0, 0, 0, 0),
(39, NULL, NULL, 'Sébastien Gauthier', 31, 'Male', 75.50, 'B+', '2022-11-05', 1, 5, 'email', 'sebastien.gauthier@email.com', 'individual', 'Frequent donor', '2022-10-26', 2, 'Kirkland', 86, 0, 0, 1, 0, 0, 0, 0, 0),
(40, NULL, NULL, 'Mélanie Rochon', 26, 'Female', 64.70, 'A-', '2023-02-12', 1, 3, 'phone', '514-456-7891', 'individual', 'New donor', '2023-02-02', 1, 'Beaconsfield', 23, 0, 0, 0, 0, 1, 0, 0, 0),
(41, NULL, NULL, 'Vincent Lajoie', 37, 'Male', 82.90, 'O+', '2023-01-25', 1, 4, 'email', 'vincent.lajoie@email.com', 'individual', 'Occasional donor', '2023-01-15', 1, 'Montreal', 42, 0, 0, 0, 0, 0, 0, 1, 0),
(42, NULL, NULL, 'Amélie Poirier', 32, 'Female', 69.80, 'AB-', '2022-10-05', 1, 2, 'phone', '418-654-3210', 'individual', 'Regular donor', '2022-09-25', 2, 'Quebec City', 154, 0, 0, 0, 1, 0, 0, 0, 0),
(43, NULL, NULL, 'Tristan Fournier', 29, 'Male', 76.10, 'B-', '2023-02-18', 1, 5, 'email', 'tristan.fournier@email.com', 'individual', 'First-time donor', '2023-02-08', 1, 'Laval', 17, 0, 0, 0, 0, 0, 1, 0, 0),
(44, NULL, NULL, 'Léa Pelletier', 43, 'Female', 62.20, 'A+', '2022-12-20', 1, 7, 'phone', '514-765-4321', 'individual', 'Dedicated donor', '2022-12-10', 2, 'Sherbrooke', 48, 1, 0, 0, 0, 0, 0, 0, 0),
(45, NULL, NULL, 'Mathieu Bélanger', 38, 'Male', 83.60, 'AB+', '2023-01-10', 1, 3, 'email', 'mathieu.belanger@email.com', 'individual', 'Occasional donor', '2023-01-01', 1, 'Gatineau', 57, 0, 0, 0, 0, 0, 0, 0, 1),
(46, NULL, NULL, 'Isaac Thibault', 25, 'Male', 70.30, 'O-', '2023-03-21', 1, 4, 'phone', '418-876-5432', 'individual', 'New donor', '2023-03-11', 1, 'Longueuil', 0, 0, 1, 0, 0, 0, 0, 0, 0),
(47, NULL, NULL, 'Olivia Martin', 28, 'Female', 65.20, 'A-', '2023-02-25', 1, 3, 'email', 'olivia.martin@email.com', 'individual', 'First-time donor', '2023-02-15', 2, 'Trois-Rivières', 12, 0, 0, 0, 0, 1, 0, 0, 0),
(48, NULL, NULL, 'Noah Thompson', 31, 'Male', 81.60, 'B+', '2022-12-12', 1, 7, 'phone', '514-321-6543', 'individual', 'Regular donor', '2022-12-02', 1, 'Drummondville', 56, 0, 0, 1, 0, 0, 0, 0, 0),
(49, NULL, NULL, 'Emma Clark', 35, 'Female', 60.80, 'O+', '2023-01-18', 1, 5, 'email', 'emma.clark@email.com', 'individual', 'Dedicated donor', '2023-01-08', 1, 'Brossard', 49, 0, 0, 0, 0, 0, 0, 1, 0),
(50, NULL, NULL, 'Liam Johnson', 42, 'Male', 88.40, 'AB-', '2023-03-01', 1, 2, 'phone', '418-987-6543', 'individual', 'Active donor', '2023-02-19', 2, 'Blainville', 5, 0, 0, 0, 1, 0, 0, 0, 0);

-- --------------------------------------------------------

--
-- Table structure for table `donor_history`
--

CREATE TABLE `donor_history` (
  `history_id` int(10) UNSIGNED NOT NULL COMMENT 'Unique identifier for each donor history record',
  `donor_id` int(10) UNSIGNED DEFAULT NULL COMMENT 'Identifier for the donor',
  `donation_id` int(10) UNSIGNED DEFAULT NULL COMMENT 'Identifier for the donation associated with this donor history',
  `reaction` enum('none','mild','severe') DEFAULT NULL COMMENT 'Type of reaction experienced by the donor post-donation (none, mild, or severe)',
  `notes` text DEFAULT NULL COMMENT 'Additional notes or details about the donor’s history'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `donor_history`
--

INSERT INTO `donor_history` (`history_id`, `donor_id`, `donation_id`, `reaction`, `notes`) VALUES
(1, 1, 1, 'none', 'No reaction, donor felt fine'),
(2, 2, 2, 'mild', 'Mild dizziness after donation'),
(3, 3, 3, 'none', 'Everything normal'),
(4, 4, 4, 'none', 'No issues reported'),
(5, 5, 5, 'severe', 'Severe nausea post-donation'),
(6, 6, 6, 'mild', 'Mild fatigue after donating'),
(7, 7, 7, 'none', 'Donor in good condition post-donation'),
(8, 8, 8, 'none', 'No adverse reactions'),
(9, 9, 9, 'mild', 'Slight dizziness, but recovered quickly'),
(10, 10, 10, 'none', 'Donor felt normal throughout'),
(11, 11, 11, 'none', 'No reactions post-donation'),
(12, 12, 12, 'mild', 'Mild arm pain at donation site'),
(13, 13, 13, 'none', 'Donor did well, no complaints'),
(14, 14, 14, 'none', 'All went smoothly'),
(15, 15, 15, 'severe', 'Fainted post-donation, medical attention required'),
(16, 16, 16, 'mild', 'Feeling of light-headedness'),
(17, 17, 17, 'none', 'No issues after donation'),
(18, 18, 18, 'none', 'Donor felt fine after procedure'),
(19, 19, 19, 'mild', 'Mild nausea, resolved after resting'),
(20, 20, 20, 'none', 'No complications or reactions');

-- --------------------------------------------------------

--
-- Table structure for table `hospitals`
--

CREATE TABLE `hospitals` (
  `hospital_id` int(10) UNSIGNED NOT NULL COMMENT 'Unique identifier for each hospital',
  `name` varchar(255) NOT NULL COMMENT 'Name of the hospital',
  `street_address` varchar(255) NOT NULL COMMENT 'Street address including building number and street name.',
  `city` varchar(100) NOT NULL COMMENT 'City or municipality where the hospital is located.',
  `province` varchar(100) NOT NULL DEFAULT 'Quebec' COMMENT 'Province or state where the hospital is situated.',
  `postal_code` varchar(7) NOT NULL COMMENT 'Postal or ZIP code of the hospital''s location.',
  `country` varchar(100) NOT NULL DEFAULT 'Canada' COMMENT 'Country in which the hospital operates.',
  `phone_number` varchar(255) NOT NULL COMMENT 'Primary contact phone number for the hospital',
  `email_address` varchar(255) NOT NULL COMMENT 'Primary contact email address for the hospital',
  `hospital_type` varchar(255) DEFAULT NULL COMMENT 'Type of hospital',
  `operating_hours` varchar(255) DEFAULT NULL COMMENT 'Operating hours of the hospital',
  `accreditation_status` varchar(255) DEFAULT NULL COMMENT 'Accreditation status of the hospital',
  `emergency_contact` varchar(255) DEFAULT NULL COMMENT 'Emergency contact number for the hospital'
) ;

--
-- Dumping data for table `hospitals`
--

INSERT INTO `hospitals` (`hospital_id`, `name`, `street_address`, `city`, `province`, `postal_code`, `country`, `phone_number`, `email_address`, `hospital_type`, `operating_hours`, `accreditation_status`, `emergency_contact`) VALUES
(3, 'General Hospital', '123 Health St', 'Montreal', 'Quebec', 'H1A 2B3', 'Canada', '514-123-4567', 'info@generalhospital.com', 'General', '24/7', 'Accredited', '514-987-6543'),
(4, 'Care Hospital', '456 Care Ave', 'Quebec City', 'Quebec', 'G1C 4D5', 'Canada', '418-234-5678', 'contact@carehospital.com', 'Specialized', '8 AM - 6 PM', 'Accredited', '418-876-5432'),
(5, 'Mercy Health Center', '789 Mercy Blvd', 'Laval', 'Quebec', 'L2C 5H6', 'Canada', '450-345-6789', 'mercy@healthcenter.com', 'Clinic', '9 AM - 5 PM', 'Certified', '450-654-3210'),
(6, 'Sainte-Marie Hospital', '101 Main St', 'Sherbrooke', 'Quebec', 'J3H 4K7', 'Canada', '819-456-7890', 'info@saintemarie.com', 'General', '24/7', 'Accredited', '819-987-6543'),
(7, 'Northside Clinic', '202 North Rd', 'Gatineau', 'Quebec', 'G5N 6O8', 'Canada', '819-567-8901', 'north@clinic.com', 'Clinic', '10 AM - 8 PM', 'Certified', '819-876-5434'),
(8, 'Riverdale Medical', '303 River St', 'Longueuil', 'Quebec', 'L4P 9Q1', 'Canada', '450-678-9012', 'contact@riverdalemed.com', 'Specialized', '8 AM - 4 PM', 'Certified', '450-654-3215'),
(9, 'Eastview Health', '404 East Ave', 'Trois-Rivières', 'Quebec', 'T6R 7S2', 'Canada', '819-789-0123', 'info@eastview.com', 'General', 'Open 24 hours', 'Accredited', '819-987-6546'),
(10, 'Sunrise Hospital', '505 Sunrise Way', 'Drummondville', 'Quebec', 'D8S 5T3', 'Canada', '819-890-1234', 'sunrise@hospital.com', 'General', '24/7', 'Accredited', '819-876-5437'),
(11, 'Maplewood Clinic', '606 Maple St', 'Brossard', 'Quebec', 'B9R 8U4', 'Canada', '450-901-2345', 'maplewood@clinic.com', 'Clinic', '9 AM - 5 PM', 'Certified', '450-654-3218'),
(12, 'Lakeside Health Center', '707 Lake Rd', 'Blainville', 'Quebec', 'B1N 2P5', 'Canada', '450-012-3456', 'lakeside@healthcenter.com', 'Specialized', '7 AM - 7 PM', 'Certified', '450-987-6549'),
(13, 'Green Valley Hospital', '808 Green St', 'Saint-Jean-sur-Richelieu', 'Quebec', 'J2W 3E6', 'Canada', '450-123-4567', 'contact@greenvalley.com', 'General', '24/7', 'Accredited', '450-876-5430'),
(14, 'Harborview Medical', '909 Harbor Blvd', 'Granby', 'Quebec', 'G3B 6H7', 'Canada', '450-234-5678', 'info@harborview.com', 'Clinic', '8 AM - 8 PM', 'Certified', '450-654-3211'),
(15, 'Mountainview Clinic', '110 Mountain Rd', 'Repentigny', 'Quebec', 'R4H 8J9', 'Canada', '450-345-6789', 'mountainview@clinic.com', 'Clinic', '10 AM - 6 PM', 'Certified', '450-987-6541'),
(16, 'Riverside Hospital', '121 Riverside Dr', 'Mascouche', 'Quebec', 'M5S 1R2', 'Canada', '450-456-7890', 'riverside@hospital.com', 'General', '24/7', 'Accredited', '450-876-5432'),
(17, 'Valley Health Center', '131 Valley St', 'Côte-Saint-Luc', 'Quebec', 'C6V 4B3', 'Canada', '514-567-8901', 'valley@healthcenter.com', 'Specialized', '9 AM - 7 PM', 'Certified', '514-654-3213'),
(18, 'West End Medical', '141 West Ave', 'Dollard-Des Ormeaux', 'Quebec', 'D9O 5L4', 'Canada', '514-678-9012', 'westend@medical.com', 'Clinic', '8 AM - 6 PM', 'Certified', '514-987-6544'),
(19, 'Cityview Clinic', '151 City Rd', 'Pointe-Claire', 'Quebec', 'P7C 6K5', 'Canada', '514-789-0123', 'cityview@clinic.com', 'Clinic', '9 AM - 5 PM', 'Certified', '514-876-5435'),
(20, 'Parkside Hospital', '161 Park St', 'Dorval', 'Quebec', 'D1V 7L6', 'Canada', '514-890-1234', 'parkside@hospital.com', 'General', '24/7', 'Accredited', '514-654-3216'),
(21, 'Springfield Medical Center', '171 Spring Rd', 'Kirkland', 'Quebec', 'K2M 8N7', 'Canada', '514-901-2345', 'springfield@medcenter.com', 'Specialized', '7 AM - 10 PM', 'Certified', '514-987-6547'),
(22, 'Oakwood Hospital', '181 Oak St', 'Beaconsfield', 'Quebec', 'B3C 9P8', 'Canada', '514-012-3456', 'oakwood@hospital.com', 'General', '24/7', 'Accredited', '514-876-5438');

-- --------------------------------------------------------

--
-- Table structure for table `recipients`
--

CREATE TABLE `recipients` (
  `recipient_id` int(11) UNSIGNED NOT NULL COMMENT 'Unique identifier for each recipient',
  `hospital_id` int(10) UNSIGNED DEFAULT NULL COMMENT 'Unique identifier for each hospital',
  `name` varchar(255) NOT NULL COMMENT 'Full name of the blood recipient',
  `age` int(11) UNSIGNED NOT NULL COMMENT 'Age of the recipient',
  `blood_group` varchar(3) NOT NULL COMMENT 'Blood group of the recipient',
  `required_date` date NOT NULL COMMENT 'Date when the blood is required for the recipient',
  `urgency` enum('low','medium','high') NOT NULL DEFAULT 'medium' COMMENT 'Describes the urgency level of the request',
  `location` varchar(255) DEFAULT NULL COMMENT 'Location of the recipient'
) ;

--
-- Dumping data for table `recipients`
--

INSERT INTO `recipients` (`recipient_id`, `hospital_id`, `name`, `age`, `blood_group`, `required_date`, `urgency`, `location`) VALUES
(1, NULL, 'Alex Johnson', 45, 'A+', '2023-06-15', 'medium', 'Gatineau'),
(2, NULL, 'Maria Rodriguez', 37, 'O-', '2023-07-20', 'low', 'Longueuil'),
(3, 3, 'David Smith', 29, 'B+', '2023-05-11', 'high', 'Granby'),
(4, 4, 'Emma Wilson', 53, 'AB-', '2023-08-04', 'medium', 'Dollard-Des Ormeaux'),
(5, 5, 'Michael Brown', 62, 'A-', '2023-09-09', 'low', 'Repentigny'),
(6, 6, 'Sophia Davis', 26, 'O+', '2023-10-12', 'high', 'Dollard-Des Ormeaux'),
(7, 7, 'James Garcia', 34, 'B-', '2023-11-06', 'medium', 'Mascouche'),
(8, 8, 'Isabella Martinez', 47, 'AB+', '2023-04-21', 'low', 'Laval'),
(9, 9, 'William Anderson', 39, 'A+', '2023-03-15', 'high', 'Longueuil'),
(10, 10, 'Olivia Thomas', 55, 'O-', '2023-12-20', 'medium', 'Repentigny'),
(11, 11, 'Benjamin Lee', 43, 'B+', '2023-01-11', 'low', 'Mascouche'),
(12, 12, 'Charlotte Jones', 50, 'AB-', '2023-02-04', 'high', 'Gatineau'),
(13, 13, 'Lucas White', 28, 'A-', '2023-06-09', 'medium', 'Sherbrooke'),
(14, 14, 'Mia Harris', 31, 'O+', '2023-07-12', 'low', 'Saint-Jean-sur-Richelieu'),
(15, 15, 'Mason Clark', 36, 'B-', '2023-05-06', 'high', 'Dollard-Des Ormeaux'),
(16, 16, 'Amelia Young', 41, 'AB+', '2023-03-21', 'medium', 'Drummondville'),
(17, 17, 'Elijah Allen', 59, 'A+', '2023-11-15', 'low', 'Longueuil'),
(18, 18, 'Harper Walker', 24, 'O-', '2023-08-20', 'high', 'Côte-Saint-Luc'),
(19, 19, 'Ethan King', 38, 'B+', '2023-09-11', 'medium', 'Brossard'),
(20, 20, 'Ava Wright', 48, 'AB-', '2023-04-04', 'low', 'Brossard');

-- --------------------------------------------------------

--
-- Table structure for table `tasks`
--

CREATE TABLE `tasks` (
  `task_id` int(10) UNSIGNED NOT NULL COMMENT 'Unique identifier for each task',
  `description` varchar(255) DEFAULT NULL COMMENT 'Detailed description of the task'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `tasks`
--

INSERT INTO `tasks` (`task_id`, `description`) VALUES
(1, 'Blood collection'),
(2, 'Equipment maintenance'),
(3, 'Data entry'),
(4, 'Lab equipment calibration'),
(5, 'Blood typing and testing'),
(6, 'Inventory management'),
(7, 'Donor screening'),
(8, 'Quality control'),
(9, 'Regulatory compliance'),
(10, 'Patient data recording'),
(11, 'Blood collection'),
(12, 'Equipment maintenance'),
(13, 'Data entry'),
(14, 'Lab equipment calibration'),
(15, 'Blood typing and testing'),
(16, 'Inventory management'),
(17, 'Donor screening'),
(18, 'Quality control'),
(19, 'Regulatory compliance'),
(20, 'Patient data recording'),
(21, 'Staff training'),
(22, 'Blood storage management'),
(23, 'Donation appointment scheduling'),
(24, 'Public awareness campaign'),
(25, 'Emergency response planning'),
(26, 'Medical record keeping'),
(27, 'Facility cleaning and sterilization'),
(28, 'Supply chain coordination'),
(29, 'Health and safety audit'),
(30, 'Volunteer coordination');

-- --------------------------------------------------------

--
-- Table structure for table `technicians`
--

CREATE TABLE `technicians` (
  `technician_id` int(10) UNSIGNED NOT NULL COMMENT 'Unique identifier for each technician',
  `hospital_id` int(10) UNSIGNED DEFAULT NULL COMMENT 'Identifier for the primary hospital where the technician works.',
  `assigned_hospital_id` int(10) UNSIGNED DEFAULT NULL COMMENT 'Identifier for the secondary hospital where the technician may be assigned.',
  `name` varchar(255) NOT NULL COMMENT 'Full name of the technician.',
  `qualification` varchar(255) DEFAULT NULL COMMENT 'Professional qualifications and certifications of the technician.',
  `phone_number` varchar(255) NOT NULL COMMENT 'Primary contact phone number for the technician',
  `email_address` varchar(255) NOT NULL COMMENT 'Primary contact email address for the technician'
) ;

--
-- Dumping data for table `technicians`
--

INSERT INTO `technicians` (`technician_id`, `hospital_id`, `assigned_hospital_id`, `name`, `qualification`, `phone_number`, `email_address`) VALUES
(3, NULL, NULL, 'Alex Tremblay', 'Certified Phlebotomist', '514-111-2222', 'alext@example.com'),
(4, NULL, NULL, 'Jordan Beaupre', 'Medical Lab Technician', '418-333-4444', 'jordanb@example.com'),
(5, NULL, NULL, 'Samira Patel', 'Certified Phlebotomist', '514-000-0001', 'tech1@example.com'),
(6, NULL, NULL, 'Ethan Wong', 'Medical Lab Technician', '514-000-0002', 'tech2@example.com'),
(7, NULL, NULL, 'Nadia Morales', 'Clinical Laboratory Technologist', '514-000-0003', 'tech3@example.com'),
(8, NULL, NULL, 'Liam Nguyen', 'Biomedical Scientist', '514-000-0004', 'tech4@example.com'),
(9, NULL, NULL, 'Ava Chen', 'Blood Bank Specialist', '514-000-0005', 'tech5@example.com'),
(10, NULL, NULL, 'Mason Kim', 'Clinical Biochemist', '514-000-0006', 'tech6@example.com'),
(11, NULL, NULL, 'Olivia Sanchez', 'Hematology Technician', '514-000-0007', 'tech7@example.com'),
(12, NULL, NULL, 'Noah Schwartz', 'Immunology Technician', '514-000-0008', 'tech8@example.com'),
(13, NULL, NULL, 'Isabella Rossi', 'Laboratory Supervisor', '514-000-0009', 'tech9@example.com'),
(14, NULL, NULL, 'Jacob Cohen', 'Pathology Assistant', '514-000-0010', 'tech10@example.com'),
(15, NULL, NULL, 'Sophia Kaur', 'Phlebotomy Technician', '514-000-0011', 'tech11@example.com'),
(16, NULL, NULL, 'Lucas Garcia', 'Toxicology Technician', '514-000-0012', 'tech12@example.com'),
(17, NULL, NULL, 'Emma Johnson', 'Clinical Research Technician', '514-000-0013', 'tech13@example.com'),
(18, NULL, NULL, 'Logan Lee', 'Diagnostic Technician', '514-000-0014', 'tech14@example.com'),
(19, NULL, NULL, 'Amelia Brown', 'Blood Transfusion Officer', '514-000-0015', 'tech15@example.com'),
(20, NULL, NULL, 'Aiden Smith', 'Medical Laboratory Assistant', '514-000-0016', 'tech16@example.com'),
(21, NULL, NULL, 'Mia Martinez', 'Quality Control Analyst', '514-000-0017', 'tech17@example.com'),
(22, NULL, NULL, 'Benjamin Anderson', 'Serology Technician', '514-000-0018', 'tech18@example.com'),
(23, NULL, NULL, 'Charlotte Davis', 'Tissue Typing Specialist', '514-000-0019', 'tech19@example.com'),
(24, NULL, NULL, 'Jack Rodriguez', 'Clinical Trials Coordinator', '514-000-0020', 'tech20@example.com');

-- --------------------------------------------------------

--
-- Table structure for table `technician_tasks`
--

CREATE TABLE `technician_tasks` (
  `technician_id` int(10) UNSIGNED NOT NULL COMMENT 'Identifier for the technician',
  `task_id` int(10) UNSIGNED NOT NULL COMMENT 'Identifier for the task assigned to the technician'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `technician_tasks`
--

INSERT INTO `technician_tasks` (`technician_id`, `task_id`) VALUES
(3, 1),
(4, 2),
(5, 3),
(6, 4),
(7, 5),
(8, 6),
(9, 7),
(10, 8),
(11, 9),
(12, 10),
(13, 11),
(14, 12),
(15, 13),
(16, 14),
(17, 15),
(18, 16),
(19, 17),
(20, 18),
(21, 19),
(22, 20);

-- --------------------------------------------------------

--
-- Structure for view `blood_stock_levels`
--
DROP TABLE IF EXISTS `blood_stock_levels`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `blood_stock_levels`  AS SELECT `blood_inventory`.`blood_group` AS `blood_group`, `blood_inventory`.`quality` AS `quality`, `blood_inventory`.`status` AS `status`, sum(`blood_inventory`.`units_available`) AS `total_units` FROM `blood_inventory` GROUP BY `blood_inventory`.`blood_group`, `blood_inventory`.`quality`, `blood_inventory`.`status` ;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `audit_log`
--
ALTER TABLE `audit_log`
  ADD PRIMARY KEY (`audit_id`);

--
-- Indexes for table `blood_inventory`
--
ALTER TABLE `blood_inventory`
  ADD PRIMARY KEY (`inventory_id`),
  ADD KEY `fk_blood_inventory_donation_id` (`donation_id`),
  ADD KEY `fk_blood_inventory_recipient_id` (`recipient_id`);

--
-- Indexes for table `blood_tests`
--
ALTER TABLE `blood_tests`
  ADD PRIMARY KEY (`test_id`),
  ADD KEY `idx_technician_id` (`technician_id`),
  ADD KEY `fk_donor_id` (`donor_id`) USING BTREE;

--
-- Indexes for table `donations`
--
ALTER TABLE `donations`
  ADD PRIMARY KEY (`donation_id`),
  ADD UNIQUE KEY `idx_blood_bag_serial` (`bag_serial_number`),
  ADD KEY `fk_donor_id` (`donor_id`),
  ADD KEY `fk_donations_hospital_id` (`hospital_id`),
  ADD KEY `idx_recipient_id` (`recipient_id`),
  ADD KEY `idx_collection_technician_id` (`collection_technician_id`),
  ADD KEY `fk_processed_by_technician_id` (`processed_by_technician_id`);

--
-- Indexes for table `donors`
--
ALTER TABLE `donors`
  ADD PRIMARY KEY (`donor_id`);

--
-- Indexes for table `donor_history`
--
ALTER TABLE `donor_history`
  ADD PRIMARY KEY (`history_id`),
  ADD KEY `donor_id` (`donor_id`),
  ADD KEY `donation_id` (`donation_id`);

--
-- Indexes for table `hospitals`
--
ALTER TABLE `hospitals`
  ADD PRIMARY KEY (`hospital_id`);

--
-- Indexes for table `recipients`
--
ALTER TABLE `recipients`
  ADD PRIMARY KEY (`recipient_id`),
  ADD KEY `fk_recipients_hospital_id_new` (`hospital_id`);

--
-- Indexes for table `tasks`
--
ALTER TABLE `tasks`
  ADD PRIMARY KEY (`task_id`);

--
-- Indexes for table `technicians`
--
ALTER TABLE `technicians`
  ADD PRIMARY KEY (`technician_id`),
  ADD KEY `fk_technicians_hospital_id` (`hospital_id`),
  ADD KEY `fk_assigned_hospital_id` (`assigned_hospital_id`);

--
-- Indexes for table `technician_tasks`
--
ALTER TABLE `technician_tasks`
  ADD PRIMARY KEY (`technician_id`,`task_id`),
  ADD KEY `task_id` (`task_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `audit_log`
--
ALTER TABLE `audit_log`
  MODIFY `audit_id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Unique identifier for each audit log entry';

--
-- AUTO_INCREMENT for table `blood_inventory`
--
ALTER TABLE `blood_inventory`
  MODIFY `inventory_id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Unique identifier for inventory items';

--
-- AUTO_INCREMENT for table `blood_tests`
--
ALTER TABLE `blood_tests`
  MODIFY `test_id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Unique identifier for each blood test', AUTO_INCREMENT=81;

--
-- AUTO_INCREMENT for table `donations`
--
ALTER TABLE `donations`
  MODIFY `donation_id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Unique identifier for each donation';

--
-- AUTO_INCREMENT for table `donors`
--
ALTER TABLE `donors`
  MODIFY `donor_id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Unique identifier for each donor';

--
-- AUTO_INCREMENT for table `donor_history`
--
ALTER TABLE `donor_history`
  MODIFY `history_id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Unique identifier for each donor history record', AUTO_INCREMENT=21;

--
-- AUTO_INCREMENT for table `hospitals`
--
ALTER TABLE `hospitals`
  MODIFY `hospital_id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Unique identifier for each hospital';

--
-- AUTO_INCREMENT for table `recipients`
--
ALTER TABLE `recipients`
  MODIFY `recipient_id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Unique identifier for each recipient';

--
-- AUTO_INCREMENT for table `tasks`
--
ALTER TABLE `tasks`
  MODIFY `task_id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Unique identifier for each task', AUTO_INCREMENT=31;

--
-- AUTO_INCREMENT for table `technicians`
--
ALTER TABLE `technicians`
  MODIFY `technician_id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Unique identifier for each technician';

--
-- Constraints for dumped tables
--

--
-- Constraints for table `blood_inventory`
--
ALTER TABLE `blood_inventory`
  ADD CONSTRAINT `fk_blood_inventory_donation_id` FOREIGN KEY (`donation_id`) REFERENCES `donations` (`donation_id`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_blood_inventory_recipient_id` FOREIGN KEY (`recipient_id`) REFERENCES `recipients` (`recipient_id`);

--
-- Constraints for table `blood_tests`
--
ALTER TABLE `blood_tests`
  ADD CONSTRAINT `fk_donor_id` FOREIGN KEY (`donor_id`) REFERENCES `donors` (`donor_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_technician_id_new` FOREIGN KEY (`technician_id`) REFERENCES `technicians` (`technician_id`) ON DELETE SET NULL ON UPDATE CASCADE;

--
-- Constraints for table `donations`
--
ALTER TABLE `donations`
  ADD CONSTRAINT `fk_donations_donor_id` FOREIGN KEY (`donor_id`) REFERENCES `donors` (`donor_id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_donations_hospital_id` FOREIGN KEY (`hospital_id`) REFERENCES `hospitals` (`hospital_id`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_processed_by_technician_id` FOREIGN KEY (`processed_by_technician_id`) REFERENCES `technicians` (`technician_id`) ON DELETE SET NULL ON UPDATE CASCADE;

--
-- Constraints for table `donor_history`
--
ALTER TABLE `donor_history`
  ADD CONSTRAINT `donor_history_ibfk_1` FOREIGN KEY (`donor_id`) REFERENCES `donors` (`donor_id`),
  ADD CONSTRAINT `donor_history_ibfk_2` FOREIGN KEY (`donation_id`) REFERENCES `donations` (`donation_id`);

--
-- Constraints for table `recipients`
--
ALTER TABLE `recipients`
  ADD CONSTRAINT `fk_recipients_hospital_id_new` FOREIGN KEY (`hospital_id`) REFERENCES `hospitals` (`hospital_id`) ON DELETE SET NULL ON UPDATE CASCADE;

--
-- Constraints for table `technicians`
--
ALTER TABLE `technicians`
  ADD CONSTRAINT `fk_assigned_hospital_id` FOREIGN KEY (`assigned_hospital_id`) REFERENCES `hospitals` (`hospital_id`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_technicians_hospital_id` FOREIGN KEY (`hospital_id`) REFERENCES `hospitals` (`hospital_id`) ON DELETE SET NULL ON UPDATE CASCADE;

--
-- Constraints for table `technician_tasks`
--
ALTER TABLE `technician_tasks`
  ADD CONSTRAINT `technician_tasks_ibfk_1` FOREIGN KEY (`technician_id`) REFERENCES `technicians` (`technician_id`),
  ADD CONSTRAINT `technician_tasks_ibfk_2` FOREIGN KEY (`task_id`) REFERENCES `tasks` (`task_id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
