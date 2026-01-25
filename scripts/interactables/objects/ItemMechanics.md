Interactable
└── SaveableItem          (Save-State + Popup + despawn)
	├── ZoomStoreItem     (Zoom → Store)
		├── ZoomFlipStoreItem (Zoom → Flip → Store)
	└── HotbarCollectZoomItem (Store ohne Zoom)
		 
		
- Neues Item ohne Flip → extends ZoomStoreItem
- Neues Item mit Flip → extends ZoomFlipStoreItem
- Neues Item ohne Zoom → extends HotbarCollectZoomItem
- Neues Item ohne Hotbar → extends SaveableItem
