# SRS — Leave Request Module (v0.3, draft from BA)

## 1. Purpose
Employees request leave online; managers approve it quickly.

## 2. Roles
- Employee
- Manager
- HR

## 3. Functional requirements
### 3.1 Create request
- FR-1: An employee selects leave type (Annual, Sick, Unpaid), start date, end date and a reason.
- FR-2: The reason is required for Sick leave and optional for others, etc.
- FR-3: The system calculates the number of leave days automatically.
- FR-4: An employee has 12 annual leave days per year.

### 3.2 Approval
- FR-5: The request goes to the employee's manager.
- FR-6: The manager approves or rejects the request within an appropriate time.
- FR-7: When a request is approved, the annual leave balance is reduced.
- FR-8: HR can approve any request.

### 3.3 Cancel
- FR-9: An employee can cancel a request before it is approved.
- FR-10: Approved requests cannot be changed.

### 3.4 Notifications
- FR-11: The manager gets an email when a new request is created.

## 4. Business rules
- BR-1: Leave days do not include weekends.
- BR-2: An employee cannot request more annual days than the remaining balance.
- BR-3: Sick leave longer than 2 days needs a medical certificate.
- BR-4: The system must be fast.
