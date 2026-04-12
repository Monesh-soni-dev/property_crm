// tailwind.config.js
module.exports = {
  content: [
    './app/views/**/*.{html,erb}',
    './app/helpers/**/*.rb',
    './app/javascript/**/*.js'
  ],
  theme: {
    extend: {
      fontFamily: {
        'display': ['"Playfair Display"', 'serif'],
        'sans':    ['"DM Sans"', 'sans-serif']
      },
      colors: {
        brand:  { DEFAULT: '#1a2e4a', light: '#2a4a72' },
        accent: { DEFAULT: '#e8834a', light: '#f5a870' }
      },
      borderRadius: { xl: '14px' }
    }
  }
}