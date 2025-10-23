
service = EMTServiceMock(use_mock=False)

hotels = service.search_hotels(
    city_code="DEL", 
    checkin_date="2025-09-25", 
    checkout_date="2025-09-26", 
    adults=2, 
    room_quantity=1
)

print(hotels)
