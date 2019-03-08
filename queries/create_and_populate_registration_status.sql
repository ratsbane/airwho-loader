

create table registration_status (`code` varchar(8), `description` varchar(128));

insert into registration_status (`code`, `description`) values 
('A', 'The Triennial Aircraft Registration form was mailed and has not been returned by the Post Office'),
('D', 'Expired Dealer'),
('E', 'The Certificate of Aircraft Registration was revoked by enforcement action'),
('M', 'Aircraft registered to the manufacturer under their Dealer Certificate'),
('N', 'Non-citizen Corporations which have not returned their flight hour reports'),
('R', 'Registration pending'),
('S', 'Second Triennial Aircraft Registration Form has been mailed and has not been returned by the Post Office'),
('T', 'Valid Registration from a Trainee'),
('V', 'Valid Registration'),
('W', 'Certificate of Registration has been deemed Ineffective or Invalid'),
('X', 'Enforcement Letter'),
('Z', 'Permanent Reserved'),
('1', 'Triennial Aircraft Registration form was returned by the Post Office as undeliverable'),
('2', 'N-Number Assigned – but has not yet been registered'),
('3', 'N-Number assigned as a Non Type Certificated aircraft - but has not yet been registered'),
('4', 'N-Number assigned as import - but has not yet been registered'),
('5', 'Reserved N-Number'),
('6', 'Administratively canceled'),
('7', 'Sale reported'),
('8', 'A second attempt has been made at mailing a Triennial Aircraft Registration form to the owner with no response'),
('9', 'Certificate of Registration has been revoked'),
('10', 'N-Number assigned, has not been registered and is pending cancellation'),
('11', 'N-Number assigned as a Non Type Certificated (Amateur) but has not been registered that is pending cancellation'),
('12', 'N-Number assigned as import but has not been registered that is pending cancellation'),
('13', 'Registration Expired'),
('14', 'First Notice for Re-Registration/Renewal'),
('15', 'Second Notice for Re-Registration/Renewal'),
('16', 'Registration Expired – Pending Cancellation'),
('17', 'Sale Reported – Pending Cancellation'),
('18', 'Sale Reported – Canceled'),
('19', 'Registration Pending – Pending Cancellation'),
('20', 'Registration Pending – Canceled'),
('21', 'Revoked – Pending Cancellation'),
('22', 'Revoked – Canceled'),
('23', 'Expired Dealer (Pending Cancellation'),
('24', 'Third Notice for Re-Registration/Renewal'),
('25', 'First Notice for Registration Renewal'),
('26', 'Second Notice for Registration Renewal'),
('27', 'Registration Expired'),
('28', 'Third Notice for Registration Renewal'),
('29', 'Registration Expired – Pending Cancellation');



