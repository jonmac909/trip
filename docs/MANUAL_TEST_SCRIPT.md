# Trippified Manual Test Script

> Complete button-by-button test coverage for every screen

**Instructions:** Run through each test case on iOS Simulator. Mark ✅ for pass, ❌ for fail, note any bugs.

---

## 1. SPLASH SCREEN (`/`)

### 1.1 Initial Load
| # | Action | Expected Result | Status |
|---|--------|-----------------|--------|
| 1.1.1 | Launch app cold | Splash screen appears with logo | ⬜ |
| 1.1.2 | Wait 2-3 seconds | Animation completes | ⬜ |
| 1.1.3 | Verify buttons | "Continue without account" visible | ⬜ |
| 1.1.4 | Verify buttons | "Sign in" visible | ⬜ |

### 1.2 Button Actions
| # | Action | Expected Result | Status |
|---|--------|-----------------|--------|
| 1.2.1 | Tap "Continue without account" | Navigates to Home screen | ⬜ |
| 1.2.2 | Tap "Sign in" | Navigates to Login screen | ⬜ |

---

## 2. LOGIN SCREEN (`/login`)

### 2.1 Layout
| # | Action | Expected Result | Status |
|---|--------|-----------------|--------|
| 2.1.1 | Verify header | "Welcome back" or similar title | ⬜ |
| 2.1.2 | Verify email input | Email text field present | ⬜ |
| 2.1.3 | Verify password input | Password field present (obscured) | ⬜ |
| 2.1.4 | Verify login button | "Sign in" / "Log in" button present | ⬜ |
| 2.1.5 | Verify back button | Back arrow in top left | ⬜ |

### 2.2 Interactions
| # | Action | Expected Result | Status |
|---|--------|-----------------|--------|
| 2.2.1 | Tap back button | Returns to Splash | ⬜ |
| 2.2.2 | Tap email field | Keyboard appears, cursor in field | ⬜ |
| 2.2.3 | Type email | Text appears in field | ⬜ |
| 2.2.4 | Tap password field | Focus moves to password | ⬜ |
| 2.2.5 | Type password | Obscured text appears | ⬜ |
| 2.2.6 | Tap login with valid creds | Success → Home screen | ⬜ |
| 2.2.7 | Tap login with invalid creds | Error message shown | ⬜ |
| 2.2.8 | Tap outside keyboard | Keyboard dismisses | ⬜ |

---

## 3. HOME SCREEN (`/home`)

### 3.1 Bottom Navigation
| # | Action | Expected Result | Status |
|---|--------|-----------------|--------|
| 3.1.1 | Verify 4 tabs | Trips, Explore, Saved, Profile icons visible | ⬜ |
| 3.1.2 | Trips tab selected | Trips icon highlighted/active | ⬜ |
| 3.1.3 | Tap Explore tab | Explore screen loads | ⬜ |
| 3.1.4 | Tap Saved tab | Saved screen loads | ⬜ |
| 3.1.5 | Tap Profile tab | Profile screen loads | ⬜ |
| 3.1.6 | Tap Trips tab | Returns to Trips tab | ⬜ |

### 3.2 Trips Tab - Header
| # | Action | Expected Result | Status |
|---|--------|-----------------|--------|
| 3.2.1 | Verify title | "My Trips" displayed | ⬜ |
| 3.2.2 | Verify FAB | Green + button in bottom right | ⬜ |
| 3.2.3 | Tap FAB | Navigates to Trip Setup | ⬜ |

### 3.3 Trips Tab - Sub-tabs
| # | Action | Expected Result | Status |
|---|--------|-----------------|--------|
| 3.3.1 | Verify sub-tabs | Upcoming, Drafts, Past, Wishlist visible | ⬜ |
| 3.3.2 | Upcoming selected | Underline under Upcoming | ⬜ |
| 3.3.3 | Tap Drafts tab | Drafts content shows | ⬜ |
| 3.3.4 | Tap Past tab | Past content shows | ⬜ |
| 3.3.5 | Tap Wishlist tab | Wishlist content shows | ⬜ |
| 3.3.6 | Tap Upcoming tab | Back to Upcoming | ⬜ |

### 3.4 Upcoming Tab Content
| # | Action | Expected Result | Status |
|---|--------|-----------------|--------|
| 3.4.1 | Verify trip cards | Japan Adventure, Europe Trip visible | ⬜ |
| 3.4.2 | Verify card image | Trip image on left side | ⬜ |
| 3.4.3 | Verify card title | Trip name displayed | ⬜ |
| 3.4.4 | Verify card dates | Date range displayed | ⬜ |
| 3.4.5 | Verify countdown | "In X days" badge shown | ⬜ |
| 3.4.6 | Verify cities | City route (Tokyo → Kyoto → Osaka) | ⬜ |
| 3.4.7 | Tap trip card | Navigates to Trip Dashboard | ⬜ |
| 3.4.8 | Tap pencil icon | Edit trip name (if implemented) | ⬜ |

### 3.5 Drafts Tab Content
| # | Action | Expected Result | Status |
|---|--------|-----------------|--------|
| 3.5.1 | Tap Drafts tab | Drafts content loads | ⬜ |
| 3.5.2 | Verify empty state | "No dates? No problem." message | ⬜ |
| 3.5.3 | Verify hint text | Explanation about drafts | ⬜ |

### 3.6 Past Tab Content
| # | Action | Expected Result | Status |
|---|--------|-----------------|--------|
| 3.6.1 | Tap Past tab | Past content loads | ⬜ |
| 3.6.2 | Verify empty state | "No past trips" message | ⬜ |
| 3.6.3 | Verify hint text | "Completed trips appear here" | ⬜ |

### 3.7 Wishlist Tab Content
| # | Action | Expected Result | Status |
|---|--------|-----------------|--------|
| 3.7.1 | Tap Wishlist tab | Wishlist content loads | ⬜ |
| 3.7.2 | Verify FAB hidden | FAB not visible on Wishlist | ⬜ |
| 3.7.3 | Verify input field | "Add a place to your wishlist" | ⬜ |
| 3.7.4 | Verify wishlist items | Santorini, Kyoto, Bali etc. visible | ⬜ |
| 3.7.5 | Tap input field | Keyboard appears | ⬜ |
| 3.7.6 | Type destination | Autocomplete suggestions appear | ⬜ |
| 3.7.7 | Select suggestion | Place added to wishlist | ⬜ |
| 3.7.8 | Tap wishlist place | Place detail or action appears | ⬜ |
| 3.7.9 | Tap "Plan a Trip" | Navigates to Trip Setup | ⬜ |
| 3.7.10 | Swipe left on item | Delete option appears | ⬜ |
| 3.7.11 | Tap delete | Item removed from wishlist | ⬜ |

---

## 4. TRIP SETUP SCREEN (`/trip/setup`)

### 4.1 Header
| # | Action | Expected Result | Status |
|---|--------|-----------------|--------|
| 4.1.1 | Verify back button | Arrow left in top left | ⬜ |
| 4.1.2 | Verify title | "Plan a Trip" displayed | ⬜ |
| 4.1.3 | Tap back button | Returns to Home | ⬜ |

### 4.2 Country Selection
| # | Action | Expected Result | Status |
|---|--------|-----------------|--------|
| 4.2.1 | Verify question | "Where do you want to go?" | ⬜ |
| 4.2.2 | Verify hint | "Add one or more countries" | ⬜ |
| 4.2.3 | Tap search field | Keyboard + suggestions appear | ⬜ |
| 4.2.4 | Type "Jap" | Japan suggestion appears | ⬜ |
| 4.2.5 | Tap Japan | Japan chip added below input | ⬜ |
| 4.2.6 | Type "Tha" | Thailand suggestion appears | ⬜ |
| 4.2.7 | Tap Thailand | Thailand chip added | ⬜ |
| 4.2.8 | Tap X on chip | Country removed from selection | ⬜ |

### 4.3 Trip Size Selection
| # | Action | Expected Result | Status |
|---|--------|-----------------|--------|
| 4.3.1 | Verify question | "How long is your trip?" | ⬜ |
| 4.3.2 | Verify 3 options | Short, Week-long, Long visible | ⬜ |
| 4.3.3 | Tap "Short trip" | Option selected (highlighted) | ⬜ |
| 4.3.4 | Verify duration | "1-4 days" shown | ⬜ |
| 4.3.5 | Tap "Week-long" | Selection changes | ⬜ |
| 4.3.6 | Verify duration | "5-10 days" shown | ⬜ |
| 4.3.7 | Tap "Long" | Selection changes | ⬜ |
| 4.3.8 | Verify duration | "10+ days" shown | ⬜ |

### 4.4 Continue Flow
| # | Action | Expected Result | Status |
|---|--------|-----------------|--------|
| 4.4.1 | Verify Continue button | Green "Continue" at bottom | ⬜ |
| 4.4.2 | Button disabled | Button inactive with no selections | ⬜ |
| 4.4.3 | Select country + size | Button becomes active | ⬜ |
| 4.4.4 | Tap Continue | Navigates to Recommended Routes | ⬜ |

---

## 5. RECOMMENDED ROUTES SCREEN (`/trip/routes`)

### 5.1 Layout
| # | Action | Expected Result | Status |
|---|--------|-----------------|--------|
| 5.1.1 | Verify back button | Arrow left present | ⬜ |
| 5.1.2 | Verify title | "Recommended Routes" or similar | ⬜ |
| 5.1.3 | Tap back | Returns to Trip Setup | ⬜ |

### 5.2 Route Options
| # | Action | Expected Result | Status |
|---|--------|-----------------|--------|
| 5.2.1 | Verify route cards | Multiple route options shown | ⬜ |
| 5.2.2 | Verify route info | Cities, duration, highlights | ⬜ |
| 5.2.3 | Tap route card | Route selected/highlighted | ⬜ |
| 5.2.4 | Verify map preview | Map shows selected route | ⬜ |

### 5.3 Actions
| # | Action | Expected Result | Status |
|---|--------|-----------------|--------|
| 5.3.1 | Verify CTA button | "Select Route" or "Continue" | ⬜ |
| 5.3.2 | Tap CTA | Navigates to Itinerary Builder | ⬜ |

---

## 6. EXPLORE SCREEN (via bottom nav)

### 6.1 Header
| # | Action | Expected Result | Status |
|---|--------|-----------------|--------|
| 6.1.1 | Navigate to Explore | Explore screen loads | ⬜ |
| 6.1.2 | Verify search bar | "Search destinations..." placeholder | ⬜ |
| 6.1.3 | Tap search bar | Keyboard appears | ⬜ |

### 6.2 Tab Navigation
| # | Action | Expected Result | Status |
|---|--------|-----------------|--------|
| 6.2.1 | Verify tabs | Destinations, Itineraries visible | ⬜ |
| 6.2.2 | Destinations selected | Underline active | ⬜ |
| 6.2.3 | Tap Itineraries | Itineraries tab content loads | ⬜ |
| 6.2.4 | Tap Destinations | Back to Destinations | ⬜ |

### 6.3 Destinations Tab
| # | Action | Expected Result | Status |
|---|--------|-----------------|--------|
| 6.3.1 | Verify region headers | "Asia", "Europe" etc. visible | ⬜ |
| 6.3.2 | Verify destination cards | Thailand, Japan etc. | ⬜ |
| 6.3.3 | Verify card image | Destination photo | ⬜ |
| 6.3.4 | Verify card name | Country name displayed | ⬜ |
| 6.3.5 | Tap destination card | Navigates to Destination Detail | ⬜ |
| 6.3.6 | Scroll horizontally | More destinations in region | ⬜ |
| 6.3.7 | Scroll vertically | More regions visible | ⬜ |

### 6.4 Itineraries Tab
| # | Action | Expected Result | Status |
|---|--------|-----------------|--------|
| 6.4.1 | Tap Itineraries tab | Itineraries content loads | ⬜ |
| 6.4.2 | Verify URL input | "Paste TikTok/Instagram URL" | ⬜ |
| 6.4.3 | Verify scan button | "Scan" button visible | ⬜ |
| 6.4.4 | Paste valid URL | URL appears in field | ⬜ |
| 6.4.5 | Tap Scan | Navigates to Scan Results | ⬜ |
| 6.4.6 | Verify history link | "See all" or history access | ⬜ |
| 6.4.7 | Tap history | Navigates to Explore History | ⬜ |

### 6.5 Search Flow
| # | Action | Expected Result | Status |
|---|--------|-----------------|--------|
| 6.5.1 | Tap search bar | Keyboard appears | ⬜ |
| 6.5.2 | Type "Tokyo" | Search results appear | ⬜ |
| 6.5.3 | Tap search result | Navigates to destination | ⬜ |
| 6.5.4 | Tap X / clear | Search cleared | ⬜ |
| 6.5.5 | Tap outside keyboard | Keyboard dismisses | ⬜ |

---

## 7. SCAN RESULTS SCREEN (`/saved/scan-results`)

### 7.1 Loading State
| # | Action | Expected Result | Status |
|---|--------|-----------------|--------|
| 7.1.1 | Scan valid URL | Loading animation plays | ⬜ |
| 7.1.2 | Verify "Scanning..." | Header shows scanning | ⬜ |
| 7.1.3 | Verify progress text | "Analyzing content with AI" | ⬜ |
| 7.1.4 | Verify back button | Arrow left present | ⬜ |
| 7.1.5 | Tap back during load | Returns to previous screen | ⬜ |

### 7.2 Results State
| # | Action | Expected Result | Status |
|---|--------|-----------------|--------|
| 7.2.1 | Wait for results | "Found X Places" header | ⬜ |
| 7.2.2 | Verify place cards | Places with names, images | ⬜ |
| 7.2.3 | Verify card checkbox | Selection checkbox on each | ⬜ |
| 7.2.4 | Tap checkbox | Card selected/deselected | ⬜ |
| 7.2.5 | Tap place card | Card expands or detail shows | ⬜ |
| 7.2.6 | Verify footer CTA | "Save X Places" button | ⬜ |
| 7.2.7 | Tap Save Places | Places saved, confirmation | ⬜ |
| 7.2.8 | Verify Create Trip | "Create a Trip" option | ⬜ |
| 7.2.9 | Tap Create Trip | Navigates to Trip Setup | ⬜ |

### 7.3 Error State
| # | Action | Expected Result | Status |
|---|--------|-----------------|--------|
| 7.3.1 | Scan invalid URL | Error state shows | ⬜ |
| 7.3.2 | Verify error message | "Unable to scan" or similar | ⬜ |
| 7.3.3 | Verify Try Again | "Try Again" button visible | ⬜ |
| 7.3.4 | Tap Try Again | Returns to input/previous | ⬜ |
| 7.3.5 | Verify footer hidden | No save buttons on error | ⬜ |

### 7.4 Empty State
| # | Action | Expected Result | Status |
|---|--------|-----------------|--------|
| 7.4.1 | Scan URL with no places | "No places found" message | ⬜ |
| 7.4.2 | Verify hint | "Try a different URL" | ⬜ |

---

## 8. SAVED SCREEN (via bottom nav)

### 8.1 Header & Tabs
| # | Action | Expected Result | Status |
|---|--------|-----------------|--------|
| 8.1.1 | Navigate to Saved | Saved screen loads | ⬜ |
| 8.1.2 | Verify tabs | Itineraries, Places, Links | ⬜ |
| 8.1.3 | Tap Itineraries | Itineraries content shows | ⬜ |
| 8.1.4 | Tap Places | Places content shows | ⬜ |
| 8.1.5 | Tap Links | Links content shows | ⬜ |

### 8.2 Import Row
| # | Action | Expected Result | Status |
|---|--------|-----------------|--------|
| 8.2.1 | Verify URL input | "Paste TikTok or Instagram URL" | ⬜ |
| 8.2.2 | Verify Scan button | "Scan" button beside input | ⬜ |
| 8.2.3 | Verify upload button | Image/video upload icon | ⬜ |
| 8.2.4 | Paste URL | URL appears in field | ⬜ |
| 8.2.5 | Tap Scan | Navigates to Scan Results | ⬜ |
| 8.2.6 | Tap upload | Photo picker opens | ⬜ |
| 8.2.7 | Select image | Image processing starts | ⬜ |

### 8.3 Places Tab
| # | Action | Expected Result | Status |
|---|--------|-----------------|--------|
| 8.3.1 | Tap Places tab | Places content loads | ⬜ |
| 8.3.2 | Verify city groupings | Places grouped by city | ⬜ |
| 8.3.3 | Verify city header | City name + place count | ⬜ |
| 8.3.4 | Verify place cards | Place name, image, type | ⬜ |
| 8.3.5 | Tap place card | Place detail opens | ⬜ |
| 8.3.6 | Tap city header | City detail opens | ⬜ |
| 8.3.7 | Swipe left on place | Delete option appears | ⬜ |
| 8.3.8 | Tap delete | Place removed | ⬜ |
| 8.3.9 | Swipe right (cancel) | Delete cancelled | ⬜ |

### 8.4 Itineraries Tab
| # | Action | Expected Result | Status |
|---|--------|-----------------|--------|
| 8.4.1 | Tap Itineraries tab | Itineraries list loads | ⬜ |
| 8.4.2 | Verify itinerary cards | Title, country, duration | ⬜ |
| 8.4.3 | Verify rating | Star rating shown | ⬜ |
| 8.4.4 | Verify saves count | "2.3k saves" etc. | ⬜ |
| 8.4.5 | Tap itinerary card | Itinerary detail opens | ⬜ |
| 8.4.6 | Swipe left | Delete option appears | ⬜ |
| 8.4.7 | Tap delete | Itinerary removed | ⬜ |

### 8.5 Links Tab
| # | Action | Expected Result | Status |
|---|--------|-----------------|--------|
| 8.5.1 | Tap Links tab | Links list loads | ⬜ |
| 8.5.2 | Verify link cards | Title, source, type | ⬜ |
| 8.5.3 | Verify icon | Link/video icon | ⬜ |
| 8.5.4 | Verify saved date | "2 days ago" etc. | ⬜ |
| 8.5.5 | Tap link card | Opens link detail or browser | ⬜ |
| 8.5.6 | Swipe left | Delete option appears | ⬜ |
| 8.5.7 | Tap delete | Link removed | ⬜ |

### 8.6 Empty States
| # | Action | Expected Result | Status |
|---|--------|-----------------|--------|
| 8.6.1 | Empty Places | "Nothing saved yet" message | ⬜ |
| 8.6.2 | Verify CTA | "Start Exploring" button | ⬜ |
| 8.6.3 | Tap Start Exploring | Navigates to Explore | ⬜ |

---

## 9. TRIP DASHBOARD SCREEN (`/trip/:id`)

### 9.1 Header
| # | Action | Expected Result | Status |
|---|--------|-----------------|--------|
| 9.1.1 | Navigate from Home | Trip Dashboard loads | ⬜ |
| 9.1.2 | Verify back button | Arrow left in top left | ⬜ |
| 9.1.3 | Verify trip title | Trip name displayed | ⬜ |
| 9.1.4 | Verify share button | Share icon in top right | ⬜ |
| 9.1.5 | Tap back | Returns to Home | ⬜ |
| 9.1.6 | Tap share | Share sheet opens | ⬜ |

### 9.2 Trip Info
| # | Action | Expected Result | Status |
|---|--------|-----------------|--------|
| 9.2.1 | Verify dates | "Mar 15 - Mar 28" etc. | ⬜ |
| 9.2.2 | Verify duration | "14 days" etc. | ⬜ |
| 9.2.3 | Verify countdown | "In 52 days" badge | ⬜ |

### 9.3 City Blocks
| # | Action | Expected Result | Status |
|---|--------|-----------------|--------|
| 9.3.1 | Verify city cards | Tokyo, Kyoto, Osaka cards | ⬜ |
| 9.3.2 | Verify city name | City name on card | ⬜ |
| 9.3.3 | Verify day count | "5 days" per city | ⬜ |
| 9.3.4 | Tap city card | City expands or navigates | ⬜ |

### 9.4 Day Builder Access
| # | Action | Expected Result | Status |
|---|--------|-----------------|--------|
| 9.4.1 | Verify day list | Day 1, Day 2... visible | ⬜ |
| 9.4.2 | Verify day info | Date + activities preview | ⬜ |
| 9.4.3 | Tap Day 1 | Day Builder opens | ⬜ |

### 9.5 Map View
| # | Action | Expected Result | Status |
|---|--------|-----------------|--------|
| 9.5.1 | Verify map | Apple Maps displayed | ⬜ |
| 9.5.2 | Verify markers | City markers on map | ⬜ |
| 9.5.3 | Tap marker | Marker info shows | ⬜ |
| 9.5.4 | Pinch to zoom | Map zooms | ⬜ |
| 9.5.5 | Pan map | Map scrolls | ⬜ |

### 9.6 Tickets Access
| # | Action | Expected Result | Status |
|---|--------|-----------------|--------|
| 9.6.1 | Verify tickets button | "Tickets" or icon visible | ⬜ |
| 9.6.2 | Tap tickets | Smart Tickets screen opens | ⬜ |

---

## 10. DAY BUILDER SCREEN (`/trip/:id/day/:cityName`)

### 10.1 Header
| # | Action | Expected Result | Status |
|---|--------|-----------------|--------|
| 10.1.1 | Navigate from Dashboard | Day Builder loads | ⬜ |
| 10.1.2 | Verify back button | Arrow left present | ⬜ |
| 10.1.3 | Verify day title | "Day 1" or date | ⬜ |
| 10.1.4 | Tap back | Returns to Trip Dashboard | ⬜ |

### 10.2 Day Navigation
| # | Action | Expected Result | Status |
|---|--------|-----------------|--------|
| 10.2.1 | Verify day selector | Day 1, Day 2, Day 3... | ⬜ |
| 10.2.2 | Tap Day 2 | Day 2 content loads | ⬜ |
| 10.2.3 | Swipe left | Next day | ⬜ |
| 10.2.4 | Swipe right | Previous day | ⬜ |

### 10.3 Timeline
| # | Action | Expected Result | Status |
|---|--------|-----------------|--------|
| 10.3.1 | Verify timeline | Time slots visible | ⬜ |
| 10.3.2 | Verify activities | Activity cards in timeline | ⬜ |
| 10.3.3 | Verify times | 9:00 AM, 12:00 PM etc. | ⬜ |

### 10.4 Activity Cards
| # | Action | Expected Result | Status |
|---|--------|-----------------|--------|
| 10.4.1 | Verify activity name | Activity title visible | ⬜ |
| 10.4.2 | Verify location | Place/venue name | ⬜ |
| 10.4.3 | Verify duration | "2 hours" etc. | ⬜ |
| 10.4.4 | Tap activity | Activity detail/edit opens | ⬜ |
| 10.4.5 | Long press | Drag handle appears | ⬜ |
| 10.4.6 | Drag to reorder | Activity moves | ⬜ |
| 10.4.7 | Swipe left | Delete option | ⬜ |
| 10.4.8 | Tap delete | Activity removed | ⬜ |

### 10.5 Add Activity
| # | Action | Expected Result | Status |
|---|--------|-----------------|--------|
| 10.5.1 | Verify Add button | "Add Activity" or + button | ⬜ |
| 10.5.2 | Tap Add Activity | Activity picker opens | ⬜ |
| 10.5.3 | Verify search | Search places input | ⬜ |
| 10.5.4 | Verify suggestions | Suggested activities | ⬜ |
| 10.5.5 | Tap suggestion | Activity added to day | ⬜ |
| 10.5.6 | Search custom place | Search results appear | ⬜ |
| 10.5.7 | Tap result | Activity added | ⬜ |
| 10.5.8 | Tap close/X | Picker closes | ⬜ |

---

## 11. PROFILE SCREEN (via bottom nav)

### 11.1 Header
| # | Action | Expected Result | Status |
|---|--------|-----------------|--------|
| 11.1.1 | Navigate to Profile | Profile screen loads | ⬜ |
| 11.1.2 | Verify avatar | Profile image or placeholder | ⬜ |
| 11.1.3 | Verify name | User name or "Guest" | ⬜ |

### 11.2 Menu Items
| # | Action | Expected Result | Status |
|---|--------|-----------------|--------|
| 11.2.1 | Verify My Trips | "My Trips" row visible | ⬜ |
| 11.2.2 | Verify My Tickets | "My Tickets" row visible | ⬜ |
| 11.2.3 | Verify Settings | "Settings" row visible | ⬜ |
| 11.2.4 | Tap My Trips | Navigates to trips | ⬜ |
| 11.2.5 | Tap My Tickets | My Tickets screen opens | ⬜ |
| 11.2.6 | Tap Settings | Settings screen opens | ⬜ |

### 11.3 Stats (if visible)
| # | Action | Expected Result | Status |
|---|--------|-----------------|--------|
| 11.3.1 | Verify trips count | Number of trips | ⬜ |
| 11.3.2 | Verify saved count | Saved items count | ⬜ |

---

## 12. SMART TICKETS SCREEN (`/trip/:id/tickets`)

### 12.1 Header
| # | Action | Expected Result | Status |
|---|--------|-----------------|--------|
| 12.1.1 | Navigate from Dashboard | Smart Tickets loads | ⬜ |
| 12.1.2 | Verify back button | Arrow left present | ⬜ |
| 12.1.3 | Verify title | "Smart Tickets" or "Tickets" | ⬜ |
| 12.1.4 | Tap back | Returns to Trip Dashboard | ⬜ |

### 12.2 Category Tabs
| # | Action | Expected Result | Status |
|---|--------|-----------------|--------|
| 12.2.1 | Verify tabs | Flights, Hotels, Activities, Transport | ⬜ |
| 12.2.2 | Tap Flights | Flights content loads | ⬜ |
| 12.2.3 | Tap Hotels | Hotels content loads | ⬜ |
| 12.2.4 | Tap Activities | Activities content loads | ⬜ |
| 12.2.5 | Tap Transport | Transport content loads | ⬜ |

### 12.3 Empty State
| # | Action | Expected Result | Status |
|---|--------|-----------------|--------|
| 12.3.1 | Verify empty | "No tickets yet" message | ⬜ |
| 12.3.2 | Verify Add CTA | "Add Ticket" button | ⬜ |
| 12.3.3 | Tap Add Ticket | Add options appear | ⬜ |

### 12.4 Add Ticket Options
| # | Action | Expected Result | Status |
|---|--------|-----------------|--------|
| 12.4.1 | Verify Import | "Import from Email" option | ⬜ |
| 12.4.2 | Verify Scan | "Scan QR Code" option | ⬜ |
| 12.4.3 | Verify Manual | "Add Manually" option | ⬜ |
| 12.4.4 | Tap Import | Email import flow starts | ⬜ |
| 12.4.5 | Tap Scan | QR scanner opens | ⬜ |
| 12.4.6 | Tap Manual | Manual entry form opens | ⬜ |

---

## 13. MY TICKETS SCREEN (`/profile/tickets`)

### 13.1 Header
| # | Action | Expected Result | Status |
|---|--------|-----------------|--------|
| 13.1.1 | Navigate from Profile | My Tickets loads | ⬜ |
| 13.1.2 | Verify back button | Arrow left present | ⬜ |
| 13.1.3 | Verify title | "My Tickets" | ⬜ |
| 13.1.4 | Tap back | Returns to Profile | ⬜ |

### 13.2 Filter Tabs
| # | Action | Expected Result | Status |
|---|--------|-----------------|--------|
| 13.2.1 | Verify tabs | Upcoming, Past visible | ⬜ |
| 13.2.2 | Tap Upcoming | Upcoming tickets shown | ⬜ |
| 13.2.3 | Tap Past | Past tickets shown | ⬜ |

### 13.3 Empty State
| # | Action | Expected Result | Status |
|---|--------|-----------------|--------|
| 13.3.1 | Verify empty | "No tickets yet" | ⬜ |
| 13.3.2 | Verify hint | "Travel tickets appear here" | ⬜ |

---

## 14. EXPLORE HISTORY SCREEN (`/explore/history`)

### 14.1 Header
| # | Action | Expected Result | Status |
|---|--------|-----------------|--------|
| 14.1.1 | Navigate from Explore | History screen loads | ⬜ |
| 14.1.2 | Verify back button | Arrow left present | ⬜ |
| 14.1.3 | Verify title | "History" | ⬜ |
| 14.1.4 | Tap back | Returns to Explore | ⬜ |

### 14.2 History List
| # | Action | Expected Result | Status |
|---|--------|-----------------|--------|
| 14.2.1 | Verify history items | Scanned URLs listed | ⬜ |
| 14.2.2 | Verify item info | Title, URL, date | ⬜ |
| 14.2.3 | Tap item | Re-scans or shows results | ⬜ |
| 14.2.4 | Swipe left | Delete option | ⬜ |
| 14.2.5 | Tap delete | Item removed | ⬜ |

### 14.3 Clear All
| # | Action | Expected Result | Status |
|---|--------|-----------------|--------|
| 14.3.1 | Verify Clear All | "Clear All" button if items | ⬜ |
| 14.3.2 | Tap Clear All | Confirmation dialog | ⬜ |
| 14.3.3 | Confirm clear | All history deleted | ⬜ |
| 14.3.4 | Cancel clear | History preserved | ⬜ |

### 14.4 Empty State
| # | Action | Expected Result | Status |
|---|--------|-----------------|--------|
| 14.4.1 | Verify empty | "No scan history" | ⬜ |
| 14.4.2 | Verify hint | "Scanned links appear here" | ⬜ |

---

## 15. DESTINATION DETAIL SCREEN (`/explore/destination/:id`)

### 15.1 Header
| # | Action | Expected Result | Status |
|---|--------|-----------------|--------|
| 15.1.1 | Tap destination | Detail screen loads | ⬜ |
| 15.1.2 | Verify back button | Arrow left present | ⬜ |
| 15.1.3 | Verify country name | Country name displayed | ⬜ |
| 15.1.4 | Tap back | Returns to Explore | ⬜ |

### 15.2 Hero Image
| # | Action | Expected Result | Status |
|---|--------|-----------------|--------|
| 15.2.1 | Verify hero image | Large country image | ⬜ |
| 15.2.2 | Scroll down | Image parallax effect | ⬜ |

### 15.3 Cities
| # | Action | Expected Result | Status |
|---|--------|-----------------|--------|
| 15.3.1 | Verify cities section | "Popular Cities" header | ⬜ |
| 15.3.2 | Verify city cards | City images + names | ⬜ |
| 15.3.3 | Tap city card | City Detail opens | ⬜ |

### 15.4 Actions
| # | Action | Expected Result | Status |
|---|--------|-----------------|--------|
| 15.4.1 | Verify Plan Trip CTA | "Plan a Trip" button | ⬜ |
| 15.4.2 | Tap Plan Trip | Trip Setup with country | ⬜ |
| 15.4.3 | Verify Save button | Heart or save icon | ⬜ |
| 15.4.4 | Tap Save | Added to wishlist | ⬜ |

---

## 16. CITY DETAIL SCREEN (`/explore/city/:id`)

### 16.1 Header
| # | Action | Expected Result | Status |
|---|--------|-----------------|--------|
| 16.1.1 | Tap city | City detail loads | ⬜ |
| 16.1.2 | Verify back button | Arrow left present | ⬜ |
| 16.1.3 | Verify city name | City name displayed | ⬜ |
| 16.1.4 | Tap back | Returns to previous | ⬜ |

### 16.2 Content
| # | Action | Expected Result | Status |
|---|--------|-----------------|--------|
| 16.2.1 | Verify description | City overview text | ⬜ |
| 16.2.2 | Verify highlights | Key attractions | ⬜ |
| 16.2.3 | Verify suggested stay | "3-5 days" etc. | ⬜ |

### 16.3 Actions
| # | Action | Expected Result | Status |
|---|--------|-----------------|--------|
| 16.3.1 | Verify Generate CTA | "Generate Itinerary" | ⬜ |
| 16.3.2 | Tap Generate | AI generates itinerary | ⬜ |
| 16.3.3 | Verify Save | Save to wishlist option | ⬜ |
| 16.3.4 | Tap Save | City saved | ⬜ |

---

## 17. ITINERARY PREVIEW SCREEN (`/explore/itinerary/:id`)

### 17.1 Header
| # | Action | Expected Result | Status |
|---|--------|-----------------|--------|
| 17.1.1 | Navigate to preview | Preview loads | ⬜ |
| 17.1.2 | Verify back button | Arrow left present | ⬜ |
| 17.1.3 | Verify share button | Share icon | ⬜ |
| 17.1.4 | Tap back | Returns to previous | ⬜ |
| 17.1.5 | Tap share | Share sheet opens | ⬜ |

### 17.2 Content
| # | Action | Expected Result | Status |
|---|--------|-----------------|--------|
| 17.2.1 | Verify day timeline | Day 1, Day 2... | ⬜ |
| 17.2.2 | Verify activities | Activities per day | ⬜ |
| 17.2.3 | Tap day | Day expands/collapses | ⬜ |
| 17.2.4 | Tap activity | Activity detail shows | ⬜ |

### 17.3 Map
| # | Action | Expected Result | Status |
|---|--------|-----------------|--------|
| 17.3.1 | Verify map | Route displayed on map | ⬜ |
| 17.3.2 | Verify markers | Activity locations marked | ⬜ |
| 17.3.3 | Tap marker | Info popup shows | ⬜ |

### 17.4 Actions
| # | Action | Expected Result | Status |
|---|--------|-----------------|--------|
| 17.4.1 | Verify Start Trip CTA | "Start Trip" button | ⬜ |
| 17.4.2 | Tap Start Trip | Creates trip from itinerary | ⬜ |
| 17.4.3 | Verify Edit | "Edit" option | ⬜ |
| 17.4.4 | Tap Edit | Edit mode opens | ⬜ |
| 17.4.5 | Verify Save | Save itinerary option | ⬜ |
| 17.4.6 | Tap Save | Itinerary saved | ⬜ |

---

## Test Summary

### Coverage Stats
| Module | Tests | Pass | Fail |
|--------|-------|------|------|
| Splash | 6 | ⬜ | ⬜ |
| Login | 10 | ⬜ | ⬜ |
| Home | 45 | ⬜ | ⬜ |
| Trip Setup | 18 | ⬜ | ⬜ |
| Routes | 8 | ⬜ | ⬜ |
| Explore | 25 | ⬜ | ⬜ |
| Scan Results | 18 | ⬜ | ⬜ |
| Saved | 35 | ⬜ | ⬜ |
| Trip Dashboard | 20 | ⬜ | ⬜ |
| Day Builder | 25 | ⬜ | ⬜ |
| Profile | 10 | ⬜ | ⬜ |
| Smart Tickets | 15 | ⬜ | ⬜ |
| My Tickets | 8 | ⬜ | ⬜ |
| Explore History | 12 | ⬜ | ⬜ |
| Destination Detail | 12 | ⬜ | ⬜ |
| City Detail | 10 | ⬜ | ⬜ |
| Itinerary Preview | 15 | ⬜ | ⬜ |
| **TOTAL** | **~292** | ⬜ | ⬜ |

### Bugs Found
| # | Screen | Issue | Severity | Status |
|---|--------|-------|----------|--------|
| 1 | | | | |
| 2 | | | | |
| 3 | | | | |

### Notes
_Add any observations or edge cases discovered during testing_

---

*Test script version 1.0 - Generated January 2025*
