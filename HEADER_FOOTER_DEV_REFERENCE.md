# Header & Footer - Developer Quick Reference

## 📁 File Locations

```
app/views/layouts/
├── _header.html.erb           (Header component)
├── _footer.html.erb           (Footer component)
└── application.html.erb       (Main layout that renders them)

app/assets/stylesheets/
└── header_footer.css          (Custom animations & styles)

config/
└── tailwind.config.js         (Color & font configuration)
```

---

## 🚀 Quick Modifications

### Change Logo Icon
**File:** `app/views/layouts/_header.html.erb` (Line 8)
```erb
<!-- Current -->
<svg class="w-5 h-5 fill-white" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
  <path d="M3 13h2v-2H3v2zm0 4h2v-2H3v2zm0-8h2V7H3v2zm4 4h14v-2H7v2zm0 4h14v-2H7v2zM7 7v2h14V7H7z"></path>
</svg>

<!-- Replace with different SVG -->
```

### Change Brand Colors
**File:** `tailwind.config.js`
```javascript
colors: {
  brand:  { DEFAULT: '#YOUR_COLOR_1', light: '#YOUR_COLOR_2' },
  accent: { DEFAULT: '#YOUR_ACCENT_1', light: '#YOUR_ACCENT_2' }
}
```

### Modify Header Height
**File:** `app/views/layouts/_header.html.erb` (Line 1)
```erb
<!-- Current: h-16 (64px) -->
<header class="... h-16 ...">

<!-- Options -->
h-14  <!-- 56px -->
h-16  <!-- 64px (current) -->
h-20  <!-- 80px -->
```

### Change Navigation Links
**File:** `app/views/layouts/_header.html.erb` (Line 31-35)
```erb
<!-- Add new link -->
<%= nav_link "Projects", projects_path %>

<!-- Remove link (comment out) -->
<%#= nav_link "Properties", properties_path %>
```

### Modify Footer Columns
**File:** `app/views/layouts/_footer.html.erb` (Lines vary)
```erb
<!-- Change column layout: md:col-span-1 -->
<div class="md:col-span-1">  <!-- 1/4 of grid -->
<div class="md:col-span-2">  <!-- 1/2 of grid -->
<!-- etc -->
```

---

## 🎨 Color Reference

### Using Colors in Templates
```erb
<!-- Text color -->
<span class="text-[#e8834a]">Orange text</span>
<span class="text-[#f5a870]">Light orange text</span>

<!-- Background -->
<div class="bg-[#1a2e4a]">Dark navy background</div>

<!-- Border -->
<div class="border-[#e8834a]">Orange border</div>

<!-- Shadow -->
<div class="shadow-[#e8834a]/50">Orange shadow</div>
```

### Using Tailwind Variables (Recommended)
```erb
<!-- Requires updating tailwind.config.js -->
<span class="text-accent">Orange text</span>
<div class="bg-brand">Navy background</div>
```

---

## 📝 Common Changes

### Hide Header on Specific Pages
**Option 1:** In the view
```erb
<div class="flex">
  <% if controller_name != 'devise' %>
    <%= render "layouts/header" %>
  <% end %>
</div>
```

**Option 2:** In the layout
```erb
<% unless devise_controller? %>
  <%= render "layouts/header" %>
<% end %>
```

### Hide Footer on Specific Pages
```erb
<% if show_footer %>
  <%= render "layouts/footer" %>
<% end %>
```

### Customize User Dropdown Links
**File:** `app/views/layouts/_header.html.erb` (Lines 73-79)
```erb
<!-- Add new link -->
<%= link_to "👥 Team Settings", team_settings_path, class: "block px-4 py-2.5 text-sm hover:bg-blue-50 text-gray-700 hover:text-blue-700 transition font-medium" %>

<!-- Change existing link -->
<%= link_to "📊 Dashboard", admin_dashboard_path, class: "..." %>
```

### Modify Footer Links
**File:** `app/views/layouts/_footer.html.erb` (Various lines)
```erb
<!-- Change link destination -->
<%= link_to "Features", features_path, class: "..." %>

<!-- Add new section -->
<div>
  <h4 class="text-sm font-bold text-white mb-4 uppercase tracking-wider">NEW SECTION</h4>
  <ul class="space-y-3">
    <li><a href="#" class="...">Link</a></li>
  </ul>
</div>
```

---

## 🔌 Component Usage

### Rendering in a View
```erb
<!-- Renders header and footer automatically in application.html.erb -->
<%= render "layouts/header" %>
<%= render "layouts/footer" %>
```

### Using in Custom Layouts
```erb
<!DOCTYPE html>
<html>
<head>
  <!-- head content -->
</head>
<body>
  <%= render "layouts/header" %>
  
  <%= yield %>
  
  <%= render "layouts/footer" %>
</body>
</html>
```

---

## 🎬 Animation Customization

### Change Animation Speed
**File:** `app/assets/stylesheets/header_footer.css`

```css
/* Find animation usage */
animation: float 3s ease-in-out infinite;  /* 3s = duration */
animation: glow-pulse 2s ease-in-out infinite;  /* Change 2s value */
animation: slide-down 0.3s ease-out;  /* Change 0.3s value */

/* Slower animations */
animation: float 5s ease-in-out infinite;    /* 5 seconds */
animation: glow-pulse 4s ease-in-out infinite;  /* 4 seconds */

/* Faster animations */
animation: float 2s ease-in-out infinite;    /* 2 seconds */
animation: glow-pulse 1s ease-in-out infinite;  /* 1 second */
```

### Change Easing Function
```css
/* Available easing options */
ease-in       /* Slow start, fast end */
ease-out      /* Fast start, slow end */
ease-in-out   /* Slow start and end, fast middle (current) */
linear        /* Constant speed */
cubic-bezier(0.4, 0, 0.2, 1)  /* Custom */
```

### Disable Animations
```css
/* Comment out or remove animation lines */
.animate-float {
  /* animation: float 3s ease-in-out infinite; */  /* Disabled */
}

/* Or change to no animation */
.animate-float {
  animation: none;
}
```

---

## 🔧 Responsive Design Tweaks

### Adjust Mobile Breakpoints
```erb
<!-- Current breakpoints -->
hidden sm:inline      <!-- Hidden on mobile, visible on small+ -->
hidden md:flex        <!-- Hidden on mobile/tablet, visible on desktop -->
hidden lg:inline      <!-- Hidden except on large screens -->

<!-- Change to custom breakpoints -->
hidden md:inline      <!-- Hide on mobile, show on medium+ -->
hidden xl:inline      <!-- Hide on laptop, show on extra-large -->
```

### Change Padding
```erb
<!-- Current -->
px-4 md:px-8   <!-- 16px mobile, 32px desktop -->
py-12 md:py-16 <!-- 48px mobile, 64px desktop -->

<!-- Options -->
px-2           <!-- 8px -->
px-4           <!-- 16px -->
px-6           <!-- 24px -->
px-8           <!-- 32px -->
px-12          <!-- 48px -->
```

### Change Gap/Spacing
```erb
<!-- Current -->
gap-2 md:gap-3  <!-- 8px mobile, 12px desktop -->

<!-- Options -->
gap-1           <!-- 4px -->
gap-2           <!-- 8px -->
gap-3           <!-- 12px -->
gap-4           <!-- 16px -->
gap-6           <!-- 24px -->
```

---

## 🎯 Helper Methods Used

### Custom Helpers
```ruby
# app/helpers/application_helper.rb

def nav_link(label, path)
  # Creates active-aware navigation links
  # Returns styled link with active class if current page
  <%= nav_link "Dashboard", root_path %>
end
```

### Devise Helpers
```ruby
user_signed_in?           # Boolean: check if user logged in
current_user             # Get logged in user object
destroy_user_session_path # Path to logout

# Usage
<% if user_signed_in? %>
  <%= current_user.full_name %>
  <%= link_to "Sign Out", destroy_user_session_path, method: :delete %>
<% end %>
```

### User Model Methods
```ruby
# app/models/user.rb

current_user.full_name   # Returns "John Doe"
current_user.initials    # Returns "JD"
current_user.email       # Returns "john@example.com"
current_user.role        # Returns "builder" (enum)
```

---

## 🧪 Testing Tips

### Test Responsive Layout
```bash
# Open browser DevTools (F12)
# Click device toolbar icon
# Select different device sizes
# Test: Mobile, Tablet, Desktop
```

### Test Animations
```css
/* Slow down animations in DevTools */
Settings → Animations → Slow down 10x

/* Or modify CSS temporarily */
animation-duration: 10s !important;
```

### Test Accessibility
```bash
# Browser: Use keyboard navigation
# Tab through elements
# Enter/Space on buttons
# Arrow keys on dropdowns
```

### Console Debug
```javascript
// Check computed styles
const header = document.querySelector('header');
console.log(getComputedStyle(header));

// Check animation performance
performance.mark('animation-start');
// ... watch animation ...
performance.mark('animation-end');
performance.measure('animation', 'animation-start', 'animation-end');
```

---

## 🚨 Common Issues & Solutions

### Issue: Animations Not Playing
**Solution:**
```css
/* Check if animation is enabled */
animation: none;  /* Make sure this isn't set */

/* Ensure animation property is correct */
@keyframes fade-in {
  from { opacity: 0; }
  to { opacity: 1; }
}

.animate-fade-in {
  animation: fade-in 0.5s ease-out;  /* Correct syntax */
}
```

### Issue: Dropdown Not Appearing
**Solution:**
```erb
<!-- Check z-index -->
<div class="z-50">  <!-- Must be higher than other elements -->
  <!-- Dropdown content -->
</div>

<!-- Check visibility classes -->
opacity-0 invisible  <!-- Both required to hide -->
opacity-100 visible  <!-- Both required to show -->
```

### Issue: Colors Not Applying
**Solution:**
```erb
<!-- Use bracket notation for custom colors -->
bg-[#1a2e4a]  <!-- Correct -->
bg-[1a2e4a]   <!-- Wrong (missing #) -->

<!-- Or add to tailwind.config.js -->
colors: {
  customBlue: '#1a2e4a'
}
<!-- Then use: bg-customBlue -->
```

### Issue: Mobile Layout Broken
**Solution:**
```erb
<!-- Check responsive classes -->
block md:flex    <!-- Stack on mobile, flex on desktop -->
grid grid-cols-1 md:grid-cols-4  <!-- Adapt columns -->

<!-- Remove fixed width that might overflow -->
width: 100%;  <!-- Use full width on mobile -->
max-w-6xl     <!-- Add max-width for desktop -->
```

---

## 📊 Performance Optimization

### CSS Specificity
```css
/* Good (low specificity) */
.nav-link { }

/* Avoid (high specificity) */
header nav .nav-link a { }
#main header nav a.nav-link { }
```

### Reduce Animations On Mobile
```css
@media (prefers-reduced-motion: reduce) {
  * {
    animation: none !important;
    transition: none !important;
  }
}
```

### GPU Acceleration
```css
/* Good (GPU accelerated) */
transform: translateY(-4px);
opacity: 0.8;

/* Avoid (CPU heavy) */
position: relative;
top: -4px;
```

---

## 📚 Useful Resources

### Tailwind CSS
- [Color Names](https://tailwindcss.com/docs/customizing-colors)
- [Spacing](https://tailwindcss.com/docs/customizing-spacing)
- [Responsive Design](https://tailwindcss.com/docs/responsive-design)
- [Animations](https://tailwindcss.com/docs/animation)

### CSS Animations
- [MDN Web Docs](https://developer.mozilla.org/en-US/docs/Web/CSS/animation)
- [Cubic Bezier Generator](https://cubic-bezier.com/)
- [Keyframes Example](https://developer.mozilla.org/en-US/docs/Web/CSS/@keyframes)

### Accessibility
- [WCAG Guidelines](https://www.w3.org/WAI/WCAG21/quickref/)
- [Tailwind A11y](https://tailwindcss.com/docs/utility-first#accessibility)
- [Color Contrast Checker](https://webaim.org/resources/contrastchecker/)

---

## 💾 Backup & Recovery

### Before Making Changes
```bash
# Create backup
cp app/views/layouts/_header.html.erb app/views/layouts/_header.html.erb.bak
cp app/views/layouts/_footer.html.erb app/views/layouts/_footer.html.erb.bak

# Restore if needed
cp app/views/layouts/_header.html.erb.bak app/views/layouts/_header.html.erb
```

### Git Version Control
```bash
# Check changes
git diff app/views/layouts/_header.html.erb

# Revert if needed
git checkout app/views/layouts/_header.html.erb

# See history
git log --oneline app/views/layouts/_header.html.erb
```

---

**Last Updated:** April 12, 2026  
**Version:** 2.1.4  
**Questions?** Refer to HEADER_FOOTER_DESIGN.md for full documentation
