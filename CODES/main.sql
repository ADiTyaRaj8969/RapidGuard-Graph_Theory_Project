

--THE GIVEN SQL CODE FFILE USED FOR THE ADMIN SIDE OF THR PROJECT TO MAINTAINE THE DATABASE OF THE MEMBERS AND THEI RESPECTIVE DETAILS INCLUDIING THEIR NAME,EMAIL,PASSWORD,PHONE NUMBER,ADDRESS,AGE,GENDER,BIRTHDAY,MEMBER ETC.

-- Drop the table if it already exists
DROP TABLE IF EXISTS hierarchy_members;

-- Create the hierarchy_members table with a VARCHAR type and CHECK constraint for 'position'
CREATE TABLE hierarchy_members (
    member_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    Area VARCHAR(255),
    position VARCHAR(4) NOT NULL CHECK (position IN ('RPM', 'DMD', 'CERT')),
    parent_id INT DEFAULT NULL, -- Links to hierarchy (self-referential foreign key)
    FOREIGN KEY (parent_id) REFERENCES hierarchy_members(member_id) ON DELETE CASCADE
);

-- Step 1: Inserting the RPM (Regional Program Manager)
INSERT INTO hierarchy_members (name, Area, position)
VALUES ('Ravi Kumar', 'Akashdeep', 'RPM');

-- Step 2: Inserting the DMDs (Disaster Management Directors) under the RPM
INSERT INTO hierarchy_members (name, Area, position, parent_id)
VALUES 
    ('Suresh Gupta', 'Akashdeep', 'DMD', (SELECT member_id FROM hierarchy_members WHERE name = 'Ravi Kumar')),
    ('Nisha Verma', 'Raiya Road', 'DMD', (SELECT member_id FROM hierarchy_members WHERE name = 'Ravi Kumar')),
    ('Ajay Singh', 'Anand Nagar ', 'DMD', (SELECT member_id FROM hierarchy_members WHERE name = 'Ravi Kumar'));

-- Step 3: Inserting CERT members under each DMD
-- CERTs under Suresh Gupta
INSERT INTO hierarchy_members (name, Area, position, parent_id)
VALUES 
    ('Manish Patel', 'Akashdeep', 'CERT', (SELECT member_id FROM hierarchy_members WHERE name = 'Suresh Gupta')),
    ('Neha Sharma', 'Akashdeep', 'CERT', (SELECT member_id FROM hierarchy_members WHERE name = 'Suresh Gupta')),
    ('Rahul Joshi', 'Akashdeep', 'CERT', (SELECT member_id FROM hierarchy_members WHERE name = 'Suresh Gupta'));

-- CERTs under Nisha Verma
INSERT INTO hierarchy_members (name, Area, position, parent_id)
VALUES 
    ('Ankita Pandey', 'Raiya Road', 'CERT', (SELECT member_id FROM hierarchy_members WHERE name = 'Nisha Verma')),
    ('Rakesh Tiwari', 'Raiya Road', 'CERT', (SELECT member_id FROM hierarchy_members WHERE name = 'Nisha Verma')),
    ('Vikas Mehta', 'Raiya Road', 'CERT', (SELECT member_id FROM hierarchy_members WHERE name = 'Nisha Verma'));

-- CERTs under Ajay Singh
INSERT INTO hierarchy_members (name, Area, position, parent_id)
VALUES 
    ('Priya Rao', 'Anand Nagar ', 'CERT', (SELECT member_id FROM hierarchy_members WHERE name = 'Ajay Singh')),
    ('Vikram Das', 'Anand Nagar ', 'CERT', (SELECT member_id FROM hierarchy_members WHERE name = 'Ajay Singh')),
    ('Gaurav Sharma', 'Anand Nagar ', 'CERT', (SELECT member_id FROM hierarchy_members WHERE name = 'Ajay Singh'));

-- Step 4: Selecting all members to display the hierarchy with member_id
SELECT member_id, name, Area, position, parent_id 
FROM hierarchy_members;