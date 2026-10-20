# Sevagan Testing Guide

## 🎯 What's Ready to Test

All core features are functional and ready for testing:
- ✅ Authentication (OTP)
- ✅ Profile Management
- ✅ Service Categories
- ✅ Job Creation & Matching
- ✅ Payments (Dev Mode)
- ✅ Ratings & Reviews
- ✅ Admin Panel
- ✅ Location Services (Google Maps)

---

## 🚀 Quick Start

### 1. Ensure Services Are Running

```bash
docker ps
```

You should see:
- `sevagan-backend` (Up)
- `sevagan-postgres` (Up)
- `sevagan-redis` (Up)
- `sevagan-admin` (Up)

### 2. Start Customer App

```bash
cd customer_app
flutter run
```

Select Chrome or Edge for web testing, or connect an Android device.

### 3. Start Technician App (in new terminal)

```bash
cd technician_app
flutter run
```

---

## 📱 Testing Scenarios

### Scenario 1: Customer Registration & Profile

**Steps:**
1. Open customer app
2. Landing screen appears with language toggle
3. Click "Customer" button
4. Enter phone number: `9876543210`
5. Click "Send OTP"
6. **Check backend logs** for OTP code:
   ```bash
   docker logs sevagan-backend --tail 20
   ```
   Look for: `Mock SMS: OTP for 9876543210 is XXXXXX`
7. Enter the OTP code
8. Profile creation screen appears
9. Fill in:
   - Name: "Test Customer"
   - Address: "123 Test Street, Chennai"
10. Click "Save Profile"
11. Home screen appears with service categories

**Expected Result:** ✅ Customer profile created and logged in

---

### Scenario 2: Technician Registration & Approval

**Steps:**
1. Open technician app
2. Click "Technician" button
3. Enter phone number: `9876543211`
4. Get OTP from backend logs
5. Enter OTP
6. Profile setup screen appears
7. Fill in:
   - Name: "Test Technician"
   - Skills: Select "Electrician", "Plumber"
   - Experience: "5 years"
   - Service Radius: "10 km"
   - Upload Aadhaar (select any image)
8. Click "Submit for Approval"
9. "Pending Approval" screen appears

**Admin Approval:**
10. Open admin panel: http://localhost:5173
11. Login: `admin@sevagan.com` / `Admin@123`
12. Go to "Technicians" tab
13. Find "Test Technician" with status "PENDING"
14. Click "Approve"
15. Status changes to "APPROVED"

**Back to Technician App:**
16. Restart technician app
17. Login again with same phone
18. Home screen appears (approved)

**Expected Result:** ✅ Technician approved and can receive jobs

---

### Scenario 3: Create Service Request (Customer)

**Prerequisites:** Customer logged in

**Steps:**
1. On home screen, click "Electrician" category
2. Service request form appears
3. Fill in:
   - Issue: "Fan not working"
   - Upload photos (optional)
   - Schedule: Toggle "Schedule for later"
   - Select date: Tomorrow
   - Select time: 10:00 AM
4. Location auto-populated from profile
5. Estimated price shown: ₹150-₹2000
6. Click "Submit Request"
7. Confirmation screen appears
8. Click "View Job Status"
9. Job status: "REQUESTED"

**Expected Result:** ✅ Service request created

---

### Scenario 4: Job Matching & Acceptance (Technician)

**Prerequisites:** 
- Technician approved and logged in
- Service request created

**Steps:**
1. **Backend automatically matches jobs** based on:
   - Location (within radius)
   - Skills (Electrician)
   - Online status

2. **Check backend logs** for job matching:
   ```bash
   docker logs sevagan-backend --tail 50
   ```
   Look for: `Notifying technicians for job...`

3. **Technician App** (without Firebase):
   - Jobs won't appear automatically (no push notifications)
   - **Workaround:** Pull to refresh on jobs screen
   - OR restart the app

4. Job request appears in "Available Jobs"
5. Shows:
   - Customer name
   - Service category
   - Issue description
   - Preferred time: Tomorrow 10:00 AM
   - Location distance
6. Click "View Details"
7. Two options:
   - "Accept Preferred Time"
   - "Propose Alternative Time"
8. Click "Accept Preferred Time"
9. Job status changes to "ACCEPTED"

**Expected Result:** ✅ Job assigned to technician

---

### Scenario 5: Job Execution

**Prerequisites:** Job accepted by technician

**Customer App:**
1. Go to "My Jobs"
2. Job status: "TECHNICIAN_ASSIGNED"
3. Technician details shown
4. Preferred visit time confirmed

**Technician App:**
1. Go to "Active Jobs"
2. Job appears with customer details
3. Click "Start Job"
4. Status changes to "JOB_STARTED"
5. Complete the work...
6. Click "Complete Job"
7. Enter final price: `500`
8. Click "Submit"
9. Status changes to "JOB_COMPLETED"

**Expected Result:** ✅ Job completed

---

### Scenario 6: Payment

**Prerequisites:** Job completed

**Customer App:**
1. Job status: "PAYMENT_PENDING"
2. Payment screen appears
3. Shows:
   - Service charge: ₹500
   - Platform fee: ₹75 (15%)
   - Total: ₹575
4. Two payment options:
   - "Pay with UPI" (Razorpay - dev mode)
   - "Cash Payment"
5. Click "Cash Payment"
6. Confirm payment
7. Status changes to "COMPLETED"

**Expected Result:** ✅ Payment recorded

---

### Scenario 7: Rating

**Prerequisites:** Payment completed

**Customer App:**
1. Rating screen appears
2. Select stars: 5 ⭐
3. Add comment: "Excellent service!"
4. Click "Submit Rating"
5. Rating saved

**Admin Panel:**
1. Go to "Technicians"
2. Find "Test Technician"
3. Rating updated: 5.0 ⭐

**Expected Result:** ✅ Rating submitted

---

## 🎛️ Admin Panel Testing

### View Analytics

1. Open: http://localhost:5173
2. Login: `admin@sevagan.com` / `Admin@123`
3. Dashboard shows:
   - Total users
   - Total jobs
   - Revenue
   - Active technicians

### Manage Service Categories

1. Go to "Services" tab
2. View all categories (10 seeded)
3. Click "Add Service"
4. Fill in:
   - Name: `carpenter`
   - English Name: "Carpenter"
   - Tamil Name: "தச்சு வேலை"
   - Base Price: 200
   - Commission: 15%
5. Click "Save"
6. New category appears

### Manage Technicians

1. Go to "Technicians" tab
2. View all technicians
3. Filter by status: "APPROVED"
4. Click on a technician
5. View details
6. Edit or disable if needed

---

## 🐛 Troubleshooting

### Issue: OTP not received

**Solution:** Check backend logs:
```bash
docker logs sevagan-backend --tail 50 | findstr "OTP"
```

### Issue: Service categories not showing

**Solution:** Check database:
```bash
docker exec sevagan-postgres psql -U sevagan_user -d sevagan -c "SELECT COUNT(*) FROM service_categories;"
```

Should show 10 categories.

### Issue: Job not appearing for technician

**Solution:** 
- Without Firebase, jobs don't push automatically
- Pull to refresh or restart app
- Check technician is approved
- Check technician skills match job category

### Issue: Maps not loading

**Solution:** Verify Google Maps API key in `.env`:
```bash
# customer_app/.env and technician_app/.env
GOOGLE_MAPS_API_KEY=AIzaSyARqBIDPunOueW3nzOKCzfEP-mBRs0jwCw
```

### Issue: Payment fails

**Solution:** 
- Using dev mode (placeholder credentials)
- Use "Cash Payment" option
- Check backend logs for errors

---

## ✅ Testing Checklist

### Customer App
- [ ] Landing screen with language toggle
- [ ] OTP login works
- [ ] Profile creation
- [ ] View service categories
- [ ] Create service request
- [ ] Schedule for later
- [ ] View job status
- [ ] Make payment
- [ ] Submit rating

### Technician App
- [ ] Landing screen
- [ ] OTP login
- [ ] Profile setup with Aadhaar
- [ ] Pending approval status
- [ ] View available jobs (after approval)
- [ ] Accept job
- [ ] Propose alternative time
- [ ] Start job
- [ ] Complete job with final price

### Admin Panel
- [ ] Login
- [ ] View dashboard analytics
- [ ] Approve/reject technicians
- [ ] Manage service categories
- [ ] View all jobs
- [ ] View payments

---

## 📊 Test Data

### Test Phone Numbers
- Customer: `9876543210`
- Technician 1: `9876543211`
- Technician 2: `9876543212`

### Admin Credentials
- Email: `admin@sevagan.com`
- Password: `Admin@123`

### Service Categories (Seeded)
1. Electrician (மின்வேலை) - ₹150
2. Plumber (குழாய் வேலை) - ₹150
3. AC Service (ஏசி சர்வீஸ்) - ₹350
4. Washing Machine (வாஷிங் மெஷின்) - ₹300
5. Motor Repair - ₹200
6. + 5 more

---

## 🚀 Next Steps After Testing

Once you've tested the core flows:

1. **Add Firebase** for push notifications
2. **Implement real-time location tracking**
3. **Add more service categories**
4. **Test on physical Android device**
5. **Prepare for Play Store deployment**

---

## 📝 Report Issues

If you find bugs during testing, note:
- What you were doing
- Expected behavior
- Actual behavior
- Screenshots if possible
- Backend logs if relevant

Happy Testing! 🎉
