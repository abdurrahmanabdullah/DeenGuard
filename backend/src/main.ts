import { ValidationPipe } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { NestFactory } from '@nestjs/core';
import { DocumentBuilder, SwaggerModule } from '@nestjs/swagger';
import * as cookieParser from 'cookie-parser';
import * as express from 'express';
import { AppModule } from './app.module';
import { HttpExceptionFilter } from './common/filters/http-exception.filter';
import { PrismaService } from './prisma/prisma.service';
//ValidationPipe → automatically validates incoming request data.
async function bootstrap() {
  const app = await NestFactory.create(AppModule, {
    rawBody: true,
  });

  const configService = app.get(ConfigService);

  app.useGlobalFilters(new HttpExceptionFilter());
  //ells NestJS to use HttpExceptionFilter for handling all errors in a consistent way.
  app.use(express.json({ limit: '5mb' }));
  app.use(express.urlencoded({ limit: '5mb', extended: true }));
  //Configures the maximum size of incoming JSON and URL-encoded data (5MB here).
  //extended: true allows nested objects in URL-encoded data.
  const postfixRouter = express.Router();
  app.use(postfixRouter);

  app.setGlobalPrefix('api');

  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      transform: true,
      forbidNonWhitelisted: true,
      validationError: {
        target: false,
      },
    }),
  );

  const prismaService = app.get(PrismaService);
  await prismaService.enableShutdownHooks(app);
  //Ensures the database connection is closed gracefully when the app shuts down.
  const corsOrigin =
    configService.get<string>('CORS_ORIGIN') || 'http://localhost:3000';
  app.enableCors({
    origin: corsOrigin.split(',').map((origin) => origin.trim()),
    credentials: true,
    methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
    allowedHeaders: ['Content-Type', 'Accept', 'Authorization'],
  });

  app.use(cookieParser());

  const swaggerConfig = new DocumentBuilder()
    .setTitle('KTTravel Backend API')
    .setDescription('API documentation for KTTravel')
    .setVersion('1.0')
    .addBearerAuth()
    .build();

  const document = SwaggerModule.createDocument(app, swaggerConfig);
  SwaggerModule.setup('api/docs', app, document);

  const port = configService.get<number>('PORT') || 5000;
  await app.listen(port, '0.0.0.0');

  console.log(`Application is running on: http://0.0.0.0:${port}`);
}

bootstrap().catch((error) => {
  console.error('Error starting the application:', error);
  process.exit(1);
});

///--------------------------------- whitelist issue discuss
// It automatically removes any properties from incoming request objects that are NOT defined in your DTOs (Data Transfer Objects).

// Example: Suppose you have a DTO like this:

// class CreateUserDto {
//   username: string;
//   email: string;
// }

// If a client sends this request:

// {
//   "username": "John",
//   "email": "john@example.com",
//   "role": "admin"
// }

// With whitelist: true, NestJS will strip out role automatically because it’s not defined in CreateUserDto.

// Why it’s needed / useful:

// Security: Prevents clients from sending extra fields that could manipulate your database or app logic.

// Data integrity: Ensures only expected fields reach your business logic.

// Cleaner code: You don’t have to manually pick which fields to keep.
