Interactable
└── SaveableItem          (Save-State + Popup + despawn)
	├── ZoomStoreItem     (Zoom → Store)
	└── ZoomFlipStoreItem (Zoom → Flip → Store)
		 └── Photo
		
- Neues Item ohne Flip → extends ZoomStoreItem
- Neues Item mit Flip → extends ZoomFlipStoreItem
- Neues Item ohne Hotbar → extends SaveableItem

└ macht man über Alt+192
─ macht man über Alt+196
├ macht man über Alt+195
║ macht man aber Alt+186
╚ macht man über Alt+200
═ macht man über Alt+205

┴ Alt+193
┼ Alt+197
┬ Alt+194
┤ Alt+180
┌ Alt+218
┐ Alt+191
┘ Alt+217
tree

projekt/
├── src/
│ ├── main.gd
│ └── util.gd
└── README.md
