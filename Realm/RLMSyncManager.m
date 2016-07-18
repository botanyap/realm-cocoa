////////////////////////////////////////////////////////////////////////////
//
// Copyright 2016 Realm Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
////////////////////////////////////////////////////////////////////////////

#import "RLMSyncManager_Private.h"

#import "RLMSyncUtil.h"
#import "RLMSyncSession_Private.h"

static RLMSyncManager *_sharedManager;

@interface RLMSyncManager ()

@property (nonatomic) NSMutableDictionary<NSString *, RLMSyncSession *> *sessions;
@property (nonatomic, readwrite) BOOL configured;
@property (nonatomic, readwrite) RLMSyncAppID appID;

@end

@implementation RLMSyncManager

+ (instancetype)sharedManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[RLMSyncManager alloc] init];
    });
    return _sharedManager;
}

- (void)configureWithAppID:(RLMSyncAppID)appID {
    if (self.configured) {
        // TODO: throw an exception?
        return;
    }
    self.appID = appID;
    self.configured = YES;
}

- (instancetype)init {
    if (self = [super init]) {
        _sessions = [NSMutableDictionary dictionary];
    }
    return self;
}

- (RLMSyncSession *)syncSessionForRealm:(NSString *)localIdentifier {
    RLMSyncSession *session = self.sessions[localIdentifier];
    if (!session) {
        // Create a new session
        session = [[RLMSyncSession alloc] init];
        session.localIdentifier = localIdentifier;
        self.sessions[localIdentifier] = session;
    }
    return session;
}

@end
