# Quick Start Guide - Testing the New Forms

## Starting the Application

```bash
cd /home/dev/Desktop/Propery_saas/builder_platform

# Run migrations (if needed)
rails db:migrate

# Start the development server
rails s

# Access at http://localhost:3000
```

---

## Testing URLs

### Authentication Pages
- **Sign Up**: `http://localhost:3000/users/sign_up`
- **Login**: `http://localhost:3000/users/sign_in`
- **Forgot Password**: `http://localhost:3000/users/password/new`

### Application Pages (require login)
- **Dashboard**: `http://localhost:3000/`
- **Properties**: `http://localhost:3000/properties`

---

## Test Cases

### ✅ Sign Up Form
1. Open `/users/sign_up`
2. Fill in:
   - First Name: John
   - Last Name: Doe
   - Email: john@example.com
   - Role: builder (or any from dropdown)
   - Password: SecurePass123!
   - Confirm Password: SecurePass123!
3. Click "Create account"
4. Should see success message and redirect to dashboard

### ✅ Login Form
1. Open `/users/sign_in`
2. Enter the email and password from signup
3. Check "Remember me" (optional)
4. Click "Sign in"
5. Should see dashboard with user profile in header

### ✅ User Profile Dropdown
1. Look at top-right corner after login
2. Click on user avatar/name button
3. Verify dropdown appears with:
   - User name
   - User email
   - Profile link
   - Sign Out link

### ✅ Header Responsiveness
1. Resize browser to mobile width (~375px)
2. Verify:
   - Logo still visible
   - Navigation still accessible
   - User profile button responsive
   - Text hides appropriately

### ✅ Footer
1. Scroll to bottom of page
2. Verify:
   - Footer is visible
   - Links are clickable
   - Responsive on mobile and desktop

### ✅ Error Handling
1. Try signup with existing email
2. Try signup with mismatched passwords
3. Try login with wrong password
4. Verify error messages appear in red box with proper styling

---

## Expected Behaviors

- ✅ Unauthenticated users redirected to login for protected pages
- ✅ Authenticated users see dashboard
- ✅ User profile dropdown shows on all pages
- ✅ Forms are responsive on all screen sizes
- ✅ Error messages styled consistently
- ✅ Form submission is smooth (Turbo)

---

## Database Users (for testing)

If you want to seed some test users:

```bash
rails console

User.create!(
  email: 'builder@example.com',
  password: 'password123',
  password_confirmation: 'password123',
  first_name: 'John',
  last_name: 'Builder',
  role: 'builder'
)

User.create!(
  email: 'admin@example.com',
  password: 'password123',
  password_confirmation: 'password123',
  first_name: 'Jane',
  last_name: 'Admin',
  role: 'admin'
)
```

---

## Troubleshooting

### "Server already running"
```bash
pkill -f 'rails s'
sleep 2
rails s
```

### "Database not migrated"
```bash
rails db:migrate
```

### "Assets not loading"
```bash
rails assets:precompile
```

### "Page styles look broken"
- Clear browser cache (Ctrl+Shift+Delete)
- Restart Rails server
- Rebuild assets: `rails assets:precompile`

---

## File Locations

| File | Purpose |
|------|---------|
| `app/views/layouts/devise.html.erb` | Auth page layout |
| `app/views/devise/sessions/new.html.erb` | Login form |
| `app/views/devise/registrations/new.html.erb` | Sign up form |
| `app/views/layouts/_header.html.erb` | Page header |
| `app/views/layouts/_footer.html.erb` | Page footer |
| `app/models/user.rb` | User model with helpers |
| `app/controllers/application_controller.rb` | Layout & auth config |

---

**Happy testing! 🚀**
