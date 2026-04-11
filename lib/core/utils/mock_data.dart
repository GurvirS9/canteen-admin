import 'package:manager_app/data/models/menu_item.dart';
import 'package:manager_app/data/models/order.dart';
import 'package:manager_app/data/models/slot.dart';
import 'package:manager_app/data/models/user.dart';

class MockData {
  MockData._();

  static final AppUser demoManager = AppUser(
    id: 'mgr-001',
    name: 'Rajesh Kumar',
    email: 'rajesh@canteen.com',
    role: 'manager',
  );

  static List<MenuItem> get menuItems => [
    MenuItem(
      id: 'mi-001',
      name: 'Paneer Butter Masala',
      description: 'Rich and creamy paneer curry with butter gravy',
      price: 180,
      category: 'Main Course',
      isAvailable: true,
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
    ),
    MenuItem(
      id: 'mi-002',
      name: 'Chicken Biryani',
      description: 'Aromatic basmati rice with tender chicken pieces',
      price: 220,
      category: 'Main Course',
      isAvailable: true,
      createdAt: DateTime.now().subtract(const Duration(days: 28)),
    ),
    MenuItem(
      id: 'mi-003',
      name: 'Masala Dosa',
      description: 'Crispy dosa with spiced potato filling',
      price: 90,
      category: 'Breakfast',
      isAvailable: true,
      createdAt: DateTime.now().subtract(const Duration(days: 25)),
    ),
    MenuItem(
      id: 'mi-004',
      name: 'Veg Sandwich',
      description: 'Grilled sandwich with fresh vegetables and cheese',
      price: 70,
      category: 'Snacks',
      isAvailable: true,
      createdAt: DateTime.now().subtract(const Duration(days: 20)),
    ),
    MenuItem(
      id: 'mi-005',
      name: 'Samosa (2 pcs)',
      description: 'Crispy fried pastry with spiced potato filling',
      price: 40,
      category: 'Snacks',
      isAvailable: false,
      createdAt: DateTime.now().subtract(const Duration(days: 22)),
    ),
    MenuItem(
      id: 'mi-006',
      name: 'Cold Coffee',
      description: 'Chilled coffee blended with ice cream',
      price: 80,
      category: 'Beverages',
      isAvailable: true,
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
    ),
    MenuItem(
      id: 'mi-007',
      name: 'Masala Chai',
      description: 'Traditional Indian spiced tea',
      price: 25,
      category: 'Beverages',
      isAvailable: true,
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
    ),
    MenuItem(
      id: 'mi-008',
      name: 'Gulab Jamun (2 pcs)',
      description: 'Soft milk dumplings soaked in sugar syrup',
      price: 50,
      category: 'Desserts',
      isAvailable: true,
      createdAt: DateTime.now().subtract(const Duration(days: 18)),
    ),
    MenuItem(
      id: 'mi-009',
      name: 'Thali Combo',
      description: 'Full meal: roti, rice, dal, sabzi, salad, sweet',
      price: 150,
      category: 'Combos',
      isAvailable: true,
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
    ),
    MenuItem(
      id: 'mi-010',
      name: 'Aloo Paratha',
      description: 'Stuffed potato paratha with butter and curd',
      price: 60,
      category: 'Breakfast',
      isAvailable: true,
      createdAt: DateTime.now().subtract(const Duration(days: 27)),
    ),
  ];

  static List<Order> get orders => [
    Order(
      id: 'ORD-1001',
      customerName: 'Amit Sharma',
      customerPhone: '9876543210',
      status: OrderStatus.pending,
      slotId: 'slot-002',
      createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
      notes: 'Extra spicy please',
      items: [
        const OrderItem(menuItemId: 'mi-001', name: 'Paneer Butter Masala', quantity: 1, price: 180),
        const OrderItem(menuItemId: 'mi-007', name: 'Masala Chai', quantity: 2, price: 25),
      ],
      totalAmount: 230,
    ),
    Order(
      id: 'ORD-1002',
      customerName: 'Priya Patel',
      status: OrderStatus.preparing,
      slotId: 'slot-002',
      createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
      items: [
        const OrderItem(menuItemId: 'mi-002', name: 'Chicken Biryani', quantity: 2, price: 220),
        const OrderItem(menuItemId: 'mi-006', name: 'Cold Coffee', quantity: 2, price: 80),
      ],
      totalAmount: 600,
    ),
    Order(
      id: 'ORD-1003',
      customerName: 'Suresh Reddy',
      customerPhone: '9876543211',
      status: OrderStatus.preparing,
      slotId: 'slot-001',
      createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
      items: [
        const OrderItem(menuItemId: 'mi-009', name: 'Thali Combo', quantity: 3, price: 150),
      ],
      totalAmount: 450,
    ),
    Order(
      id: 'ORD-1004',
      customerName: 'Neha Gupta',
      status: OrderStatus.ready,
      slotId: 'slot-001',
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      items: [
        const OrderItem(menuItemId: 'mi-003', name: 'Masala Dosa', quantity: 2, price: 90),
        const OrderItem(menuItemId: 'mi-008', name: 'Gulab Jamun (2 pcs)', quantity: 1, price: 50),
      ],
      totalAmount: 230,
    ),
    Order(
      id: 'ORD-1005',
      customerName: 'Vikram Singh',
      status: OrderStatus.completed,
      slotId: 'slot-001',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      items: [
        const OrderItem(menuItemId: 'mi-004', name: 'Veg Sandwich', quantity: 4, price: 70),
        const OrderItem(menuItemId: 'mi-007', name: 'Masala Chai', quantity: 4, price: 25),
      ],
      totalAmount: 380,
    ),
    Order(
      id: 'ORD-1006',
      customerName: 'Anita Desai',
      status: OrderStatus.completed,
      slotId: 'slot-002',
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      items: [
        const OrderItem(menuItemId: 'mi-002', name: 'Chicken Biryani', quantity: 1, price: 220),
      ],
      totalAmount: 220,
    ),
    Order(
      id: 'ORD-1007',
      customerName: 'Rohit Mehra',
      status: OrderStatus.pending,
      slotId: 'slot-003',
      createdAt: DateTime.now().subtract(const Duration(minutes: 2)),
      items: [
        const OrderItem(menuItemId: 'mi-010', name: 'Aloo Paratha', quantity: 2, price: 60),
        const OrderItem(menuItemId: 'mi-006', name: 'Cold Coffee', quantity: 1, price: 80),
      ],
      totalAmount: 200,
    ),
    Order(
      id: 'ORD-1008',
      customerName: 'Kavita Joshi',
      status: OrderStatus.completed,
      slotId: 'slot-001',
      createdAt: DateTime.now().subtract(const Duration(hours: 4)),
      items: [
        const OrderItem(menuItemId: 'mi-009', name: 'Thali Combo', quantity: 1, price: 150),
        const OrderItem(menuItemId: 'mi-008', name: 'Gulab Jamun (2 pcs)', quantity: 2, price: 50),
      ],
      totalAmount: 250,
    ),
  ];

  static List<Slot> get slots => [
    const Slot(id: 'slot-001', label: 'Breakfast', startTime: '08:00 AM', endTime: '10:00 AM', isOpen: false, maxOrders: 40, currentOrders: 38),
    const Slot(id: 'slot-002', label: 'Lunch', startTime: '12:00 PM', endTime: '02:00 PM', isOpen: true, maxOrders: 60, currentOrders: 32),
    const Slot(id: 'slot-003', label: 'Evening Snacks', startTime: '04:00 PM', endTime: '06:00 PM', isOpen: true, maxOrders: 30, currentOrders: 5),
    const Slot(id: 'slot-004', label: 'Dinner', startTime: '07:00 PM', endTime: '09:00 PM', isOpen: true, maxOrders: 50, currentOrders: 0),
  ];
}
