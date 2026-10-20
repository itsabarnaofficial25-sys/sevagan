# Phase 1 Setup Guide - Database & Environment

## Overview
This guide will help you complete Phase 1 critical blockers: database setup, environment configuration, and Firebase integration.

## 1. Environment Files Setup

### Backend (Already Complete ✅)
The backend `.env` file is already configured.

### Mobile Apps (NEW)

#### Customer App
1. Copy the example file:
   ```bash
   cd customer_app
   copy .env.example .env
   ```

2. Edit `.env` and update these values:
   ```env
   API_BASE_URL=http://localhost:3000/api
   GOOGLE_MAPS_API_KEY=<your_key_here>
   RAZORPAY_KEY_ID=<your_key_here>
   ```

#### Technician App
1. Copy the example file:
   ```bash
   cd technician_app
   copy .env.example .env
   ```

2. Edit `.env` and update:
   ```env
   API_BASE_URL=http://localhost:3000/api
   GOOGLE_MAPS_API_KEY=<your_key_here>
   ```

---

## 2. Database Migrations

### Check Migration Status
```bash
cd backend
npm run typeorm migration:show -d src/database/data-source.ts
```

### Run Migrations (if not already run)
```bash
npm run migration:run
```

This will create all tables:
- users
- customers
- technicians
- service_categories
- service_requests
- payments
- ratings
- otp_codes

### Seed Service Categories
```bash
npx ts-node src/database/seeds/seed-service-categories.ts
```

This creates default service categories:
- Electrician
- Plumber
- AC Service
- Washing Machine
- Motor Repair

---

## 3. Firebase Setup

### Prerequisites
- Google account
- Firebase project created

### Steps

#### 1. Install Firebase CLI
```bash
npm install -g firebase-tools
```

#### 2. Login to Firebase
```bash
firebase login
```

#### 3. Configure Flutter Apps
```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure customer app
cd customer_app
flutterfire configure

# Configure technician app
cd ../technician_app
flutterfire configure
```

This will:
- Create `firebase_options.dart` in both apps
- Configure Android and iOS (if needed)
- Set up FCM for push notifications

#### 4. Update Backend Firebase Config
1. Go to Firebase Console → Project Settings → Service Accounts
2. Click "Generate New Private Key"
3. Download the JSON file
4. Update backend `.env`:
   ```env
   FIREBASE_PROJECT_ID=your-project-id
   FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----\n"
   FIREBASE_CLIENT_EMAIL=firebase-adminsdk-xxxxx@your-project.iam.gserviceaccount.com
   ```

---

## 4. Verification Checklist

### Database
- [ ] PostgreSQL is running (check with `docker ps`)
- [ ] Redis is running (check with `docker ps`)
- [ ] Migrations have been run successfully
- [ ] Service categories are seeded
- [ ] Can connect to database from backend

### Environment Files
- [ ] `backend/.env` exists and is configured
- [ ] `customer_app/.env` exists
- [ ] `technician_app/.env` exists
- [ ] `admin-panel/.env` exists

### Firebase
- [ ] Firebase CLI installed
- [ ] `firebase_options.dart` generated for customer_app
- [ ] `firebase_options.dart` generated for technician_app
- [ ] Backend Firebase Admin SDK configured
- [ ] FCM test notification works

---

## 5. Test the Setup

### Start Services
```bash
# Terminal 1: Start backend
cd backend
npm run start:dev

# Terminal 2: Start customer app
cd customer_app
flutter run

# Terminal 3: Start technician app
cd technician_app
flutter run
```

### Test Flow
1. **Customer App**: 
   - Open landing screen
   - Select "Customer"
   - Enter phone number
   - Receive OTP (check backend logs for mock OTP)
   - Complete profile setup
   - View home screen with service categories

2. **Technician App**:
   - Open landing screen
   - Select "Technician"
   - Enter phone number
   - Receive OTP
   - Complete profile setup
   - Wait for admin approval

3. **Admin Panel**:
   - Login at http://localhost:5173
   - Email: admin@sevagan.com
   - Password: Admin@123
   - Approve technician
   - View analytics dashboard

---

## 6. Common Issues & Solutions

### Issue: Database connection failed
**Solution**: 
```bash
docker-compose up -d postgres redis
```

### Issue: Migration already run
**Solution**: This is normal if migrations were run before. Skip to seeding.

### Issue: Firebase configuration failed
**Solution**: 
1. Ensure you're logged into Firebase CLI
2. Select the correct Firebase project
3. Enable required APIs in Firebase Console

### Issue: OTP not received in mobile apps
**Solution**: 
- Backend is using mock SMS provider by default
- Check backend console logs for the OTP code
- For production, configure MSG91 or Twilio

---

## 7. Next Steps After Phase 1

Once Phase 1 is complete:
1. ✅ Test complete auth flow (OTP → Profile → Home)
2. ✅ Verify database tables are created
3. ✅ Confirm Firebase notifications work
4. Move to Phase 2: Maps integration
5. Move to Phase 3: Payment integration

---

## Quick Reference

### Useful Commands
```bash
# Check database
docker exec -it sevagan-postgres psql -U sevagan_user -d sevagan

# Check Redis
docker exec -it sevagan-redis redis-cli

# View backend logs
docker logs sevagan-backend --tail 50 -f

# Reset database (CAUTION: Deletes all data)
npm run migration:revert
npm run migration:run
```

### Environment Variables Reference
See `.env.example` files in each directory for complete list of required variables.
