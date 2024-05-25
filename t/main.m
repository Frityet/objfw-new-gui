#import <ObjFW/ObjFW.h>

@interface OFObject(PropertyNameExtensions)

- (OFArray<OFString *> *)propertyNames;
- (OFArray<OFString *> *)propertyNamesTerminatingAtClass: (Class)cls;

@end


@implementation OFObject(PropertyNameExtensions)

- (OFArray<OFString *> *)propertyNames
{ return [self propertyNamesTerminatingAtClass: OFObject.class]; }

//gets all properties in the class and its superclasses
- (OFArray<OFString *> *)propertyNamesTerminatingAtClass: (Class)termClass
{
    auto names = [OFMutableArray<OFString *> array];

    auto cls = self.class;
    while (cls != termClass) {
        unsigned int count;
        objc_property_t *properties = class_copyPropertyList(cls, &count);
        if (properties == nil) {
            @throw [OFInitializationFailedException exceptionWithClass: cls];
        }

        for (unsigned int i = 0; i < count; i++)
            [names addObject: [OFString stringWithUTF8String: property_getName(properties[i])]];

        free(properties);
        cls = cls.superclass;
    }

    [names makeImmutable];
    return names;
}

@end

@interface OFObject(SerializationExtensions)

- (OFDictionary *)asDictionary;

@end

@implementation OFObject(SerializationExtensions)

- (id)getValues
{
	if ([self isKindOfClass: OFString.class] || [self isKindOfClass: OFNumber.class]) {
		return self;
	} else if ([self isKindOfClass: OFDictionary.class]) {
		__weak auto dict = (OFDictionary *)self;
		auto values = [OFMutableDictionary dictionary];
		for (OFString *key in dict) {
			[values setObject: [[dict objectForKey: key] getValues] forKey: key];
		}
		[values makeImmutable];
		return values;
	} else if ([self isKindOfClass: OFArray.class]) {
		__weak auto arr = (OFArray *)self;
		auto values = [OFMutableArray array];
		for (id obj in arr) {
			[values addObject: [obj getValues]];
		}
		[values makeImmutable];
		return values;
	} else {
		auto props = self.propertyNames;
		auto values = [OFMutableDictionary dictionary];

		for (OFString *prop in props) {
			@try {
				[values setObject: [[self valueForKey: prop] getValues] forKey: prop];
			} @catch(OFUndefinedKeyException *) {
				//can't be serialized cause its not an objc type or smth like that
			}
		}

		[values makeImmutable];
		return values;
	}
}

- (OFDictionary *)asDictionary
{
	id values = [self getValues];
	if ([values isKindOfClass: OFDictionary.class]) {
		return values;
	} else {
		@throw [OFInvalidArgumentException exception];
	}
}

@end

@interface Person : OFObject

@property OFString *name;
@property OFNumber *age;
@property OFArray<Person *> *friends;

@property const char *testField;

- (instancetype)initWithName: (OFString *)name age: (OFNumber *)age friends: (OFArray<Person *> *)friends;
+ (instancetype)personNamed: (OFString *)name aged: (OFNumber *)age withFriends: (OFArray<Person *> *)friends;

@end

@implementation Person

- (instancetype)initWithName: (OFString *)name age: (OFNumber *)age friends: (OFArray<Person *> *)friends
{
	self = [super init];

	_name = name;
	_age = age;
	_friends = friends ?: [OFArray array];

	_testField = "test";

	return self;
}

+ (instancetype)personNamed: (OFString *)name aged: (OFNumber *)age withFriends: (OFArray<Person *> *)friends
{ return [[self alloc] initWithName: name age: age friends: friends]; }

@end

@interface App : OFObject <OFApplicationDelegate>
@end

@implementation App

- (void)applicationDidFinishLaunching: (OFNotification *)notification
{
	auto guy = [Person personNamed: @"John" aged: @42 withFriends: [OFArray arrayWithArray: @[
		[Person personNamed: @"Alice" aged: @12 withFriends: nil],
		[Person personNamed: @"Bob" aged: @48 withFriends: nil],
		@{
			@"name": @"Charlie",
			@"age": @32,
			@"friends": [OFArray arrayWithArray: @[
				[Person personNamed: @"David" aged: @22 withFriends: nil],
				[Person personNamed: @"Eve" aged: @19 withFriends: nil]
			]]
		}
	]]];

	[OFStdOut writeFormat: @"%@\n", guy.asDictionary];
	[OFApplication terminate];
}

@end

OF_APPLICATION_DELEGATE(App);
