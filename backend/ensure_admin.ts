import { PrismaClient } from '@prisma/client';
import * as bcrypt from 'bcryptjs';

const prisma = new PrismaClient();

async function main() {
    const adminEmail = 'admin@example.com';
    const adminPassword = 'Admin@017';
    const hashedPassword = await bcrypt.hash(adminPassword, 10);

    const admin = await prisma.user.upsert({
        where: { email: adminEmail },
        update: {
            role: 'admin',
            password: hashedPassword,
        },
        create: {
            email: adminEmail,
            name: 'Admin User',
            username: 'admin',
            password: hashedPassword,
            role: 'admin',
            isActive: true,
        },
    });

    console.log('Admin user ensured:');
    console.log(JSON.stringify({ email: admin.email, role: admin.role }, null, 2));
}

main()
    .catch(e => console.error(e))
    .finally(async () => await prisma.$disconnect());
