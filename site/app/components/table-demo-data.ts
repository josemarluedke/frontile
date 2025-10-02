// Demo data for table component examples

export interface User {
  id: string;
  name: string;
  email: string;
  role: string;
  status?: 'active' | 'inactive';
}

export interface Product {
  id: string;
  name: string;
  price: number;
  category: string;
  inStock?: boolean;
}

export interface Employee {
  id: string;
  name: string;
  email: string;
  phone: string;
  department: string;
  role: string;
  location: string;
  manager: string;
}

export const users: User[] = [
  {
    id: '1',
    name: 'John Doe',
    email: 'john@example.com',
    role: 'admin',
    status: 'active',
  },
  {
    id: '2',
    name: 'Jane Smith',
    email: 'jane@example.com',
    role: 'user',
    status: 'active',
  },
  {
    id: '3',
    name: 'Bob Johnson',
    email: 'bob@example.com',
    role: 'editor',
    status: 'inactive',
  },
];

export const products: Product[] = [
  {
    id: '1',
    name: 'Laptop',
    price: 999.99,
    category: 'Electronics',
    inStock: true,
  },
  {
    id: '2',
    name: 'Mouse',
    price: 29.99,
    category: 'Accessories',
    inStock: true,
  },
  {
    id: '3',
    name: 'Keyboard',
    price: 79.99,
    category: 'Accessories',
    inStock: false,
  },
];

export const employees: Employee[] = [
  {
    id: '001',
    name: 'John Doe',
    email: 'john.doe@company.com',
    phone: '+1-555-0123',
    department: 'Engineering',
    role: 'Senior Developer',
    location: 'San Francisco, CA',
    manager: 'Alice Brown',
  },
  {
    id: '002',
    name: 'Jane Smith',
    email: 'jane.smith@company.com',
    phone: '+1-555-0124',
    department: 'Design',
    role: 'UI/UX Designer',
    location: 'New York, NY',
    manager: 'Bob Wilson',
  },
  {
    id: '003',
    name: 'Bob Johnson',
    email: 'bob.johnson@company.com',
    phone: '+1-555-0125',
    department: 'Product',
    role: 'Product Manager',
    location: 'Austin, TX',
    manager: 'Carol Davis',
  },
];
